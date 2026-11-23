# syntax=docker/dockerfile:1
ARG LANGUAGETOOL_VERSION=6.8
ARG TARGETARCH

FROM debian:bookworm@sha256:268fb24c39bca92d326dd83ea3abebe4a3f7751c804ffef23bb6d857dd343ff8 AS build

ENV DEBIAN_FRONTEND=noninteractive

# Install common packages
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update -y && \
    apt-get install -y --no-install-recommends \
        locales \
        bash \
        libgomp1 \
        openjdk-17-jdk-headless \
        git \
        maven \
        unzip \
        xmlstarlet

# Install ARM64-specific packages (cached separately)
RUN [ "$TARGETARCH" = "arm64" ] && \
    --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        mercurial \
        texlive \
        wget \
        zip || true

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8

# Global Maven settings. See maven/settings.xml for why this is needed.
COPY maven/settings.xml /etc/maven/settings.xml

ARG LANGUAGETOOL_VERSION
RUN git clone https://github.com/languagetool-org/languagetool.git --depth 1 -b v${LANGUAGETOOL_VERSION}
WORKDIR /languagetool

# Pre-download Maven dependencies using cache
RUN --mount=type=cache,target=/root/.m2 mvn dependency:go-offline -DskipTests

# Build LanguageTool standalone
RUN --mount=type=cache,target=/root/.m2 mvn --projects languagetool-standalone --also-make package -DskipTests --quiet

RUN LANGUAGETOOL_DIST_VERSION=$(xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -v "//x:project/x:properties/x:revision" pom.xml) && unzip /languagetool/languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_DIST_VERSION}.zip -d /dist
RUN LANGUAGETOOL_DIST_FOLDER=$(find /dist/ -name 'LanguageTool-*') && mv $LANGUAGETOOL_DIST_FOLDER /dist/LanguageTool

# Execute workarounds for ARM64 architectures.
# https://github.com/languagetool-org/languagetool/issues/4543
WORKDIR /
COPY --link --chmod=755 arm64-workaround/bridj.sh arm64-workaround/bridj.sh
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        echo "Applying ARM64 workaround for BridJ..." && \
        bash arm64-workaround/bridj.sh; \
    else \
        echo "Skipping ARM64 workarounds for $TARGETARCH"; \
    fi

WORKDIR /languagetool

FROM alpine:3.24.4@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf

ARG TARGETARCH

# Upgrade the packages from the base image as well, so fixes released after
# the base image was built are included.
RUN apk upgrade --no-cache && apk add --no-cache \
    bash \
    curl \
    fasttext \
    libc6-compat \
    libstdc++ \
    openjdk17-jre-headless

RUN if [ "$TARGETARCH" = "arm64" ]; then \
        apk add --no-cache hunspell zip; \
    fi

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool

COPY --chown=languagetool:languagetool --from=build /dist/LanguageTool /LanguageTool

RUN if [ "$TARGETARCH" = "arm64" ]; then \
    echo "Applying ARM64 workaround for Hunspell..."; \
    HUNSPELL_SRC=$(find /usr/lib -name 'libhunspell-*.so*' -type f | head -n 1); \
        if [ -z "$HUNSPELL_SRC" ]; then \
            echo "Unable to locate hunspell shared library in /usr/lib"; \
            exit 1; \
        fi; \
        mkdir -p /tmp/hunspell/linux-aarch64; \
        cp "$HUNSPELL_SRC" /tmp/hunspell/linux-aarch64/libhunspell.so; \
        (cd /tmp/hunspell && zip /LanguageTool/libs/hunspell.jar linux-aarch64/libhunspell.so); \
        rm -rf /tmp/hunspell; \
    fi

WORKDIR /LanguageTool

RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

COPY --chown=languagetool:languagetool start.sh config.properties ./

# The checksum matches the model shipped in erikvl87/languagetool:6.8, built in June 2026.
ARG FASTTEXT_MODEL_SHA256=7e69ec5451bc261cc7844e49e4792a85d7f09c06789ec800fc4a44aec362764e
RUN install -d -m 755 /fastText \
    && curl -fsSL https://dl.fbaipublicfiles.com/fasttext/supervised-models/lid.176.bin -o /fastText/lid.176.bin \
    && echo "${FASTTEXT_MODEL_SHA256}  /fastText/lid.176.bin" | sha256sum -c - \
    && chown -R languagetool:languagetool /fastText

RUN set -eux; \
    echo "fasttextModel=/fastText/lid.176.bin" >> config.properties; \
    echo "fasttextBinary=$(command -v fasttext)" >> config.properties; \
    chown languagetool:languagetool config.properties

USER languagetool

HEALTHCHECK --timeout=10s --start-period=5s CMD curl --fail --data "language=en-US&text=a simple test" http://localhost:8010/v2/check || exit 1

CMD ["bash", "start.sh"]

EXPOSE 8010
