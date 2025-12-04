# syntax=docker/dockerfile:1
ARG LANGUAGETOOL_VERSION=6.7
ARG TARGETARCH

FROM debian:bookworm AS build

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
COPY --link --chmod=755 arm64-workaround/hunspell.sh arm64-workaround/hunspell.sh
RUN if [ "$TARGETARCH" = "arm64" ]; then \
        echo "Applying ARM64 workarounds..." && \
        bash arm64-workaround/bridj.sh && \
        bash arm64-workaround/hunspell.sh; \
    else \
        echo "Skipping ARM64 workarounds for $TARGETARCH"; \
    fi

WORKDIR /languagetool

FROM alpine:3.23.0

RUN apk add --no-cache \
    bash \
    curl \
    libc6-compat \
    libstdc++ \
    openjdk17-jre-headless

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool

COPY --chown=languagetool:languagetool --from=build /dist/LanguageTool /LanguageTool

WORKDIR /LanguageTool

# Note: When changing the base image, verify that the hunspell.sh workaround is
# downloading the matching version of `libhunspell`. The URL may need to change.
RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

COPY --chown=languagetool:languagetool start.sh start.sh
COPY --chown=languagetool:languagetool config.properties config.properties

USER languagetool

HEALTHCHECK --timeout=10s --start-period=5s CMD curl --fail --data "language=en-US&text=a simple test" http://localhost:8010/v2/check || exit 1

CMD ["bash", "start.sh"]

EXPOSE 8010
