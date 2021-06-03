ARG LANGUAGETOOL_VERSION=5.3

FROM debian:buster as build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y \
    locales \
    bash \
    libgomp1 \
    openjdk-11-jdk-headless \
    git \
    maven \
    unzip \
    xmlstarlet \
    && apt-get clean

# https://github.com/languagetool-org/languagetool/issues/1498#issuecomment-479149558
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

# Clone and build LanguageTool.
ARG LANGUAGETOOL_VERSION
RUN git clone https://github.com/languagetool-org/languagetool.git --depth 1 -b v${LANGUAGETOOL_VERSION}
WORKDIR /languagetool
RUN ["mvn", "--projects", "languagetool-standalone", "--also-make", "package", "-DskipTests", "--quiet"]
RUN LANGUAGETOOL_DIST_VERSION=$(xmlstarlet sel -N "x=http://maven.apache.org/POM/4.0.0" -t -v "//x:project/x:properties/x:languagetool.version" pom.xml) && unzip /languagetool/languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_DIST_VERSION}.zip -d /dist
RUN LANGUAGETOOL_DIST_FOLDER=$(find /dist/ -name 'LanguageTool-*') && mv $LANGUAGETOOL_DIST_FOLDER /dist/LanguageTool

# Execute workarounds for ARM64 architectures.
# https://github.com/languagetool-org/languagetool/issues/4543
WORKDIR /
COPY arm64-workaround/. .
RUN chmod +x ./bridj.sh ./hunspell.sh
RUN bash -c "./bridj.sh"
RUN bash -c "./hunspell.sh"

# tests
RUN apt-get install -y 	libtinfo6
RUN echo $(find / -iname "libtinfo*")
RUN echo $(ls /usr/lib/aarch64-linux-gnu)

FROM alpine

RUN apk update \
    && apk add \
    bash \
    libstdc++ \
    libc6-compat \
    openjdk11-jre-headless

RUN addgroup -S languagetool && adduser -S languagetool -G languagetool
COPY --chown=languagetool --from=build /dist .

#tests
COPY --from=build /lib/aarch64-linux-gnu/libtinfo.so.6 /usr/lib/libtinfo.so.6

WORKDIR /LanguageTool
RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg
COPY --chown=languagetool start.sh start.sh
COPY --chown=languagetool config.properties config.properties
USER languagetool

CMD [ "bash", "start.sh" ]
EXPOSE 8010
