ARG LANGUAGE_TOOL_VERSION=4.5.1

FROM debian:stretch as build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y \
        bash \
        openjdk-8-jdk-headless \
        git \
        maven \
        unzip \
    && apt-get clean

ARG LANGUAGE_TOOL_VERSION

RUN git clone https://github.com/languagetool-org/languagetool.git --depth 1 -b v${LANGUAGE_TOOL_VERSION}

WORKDIR /languagetool

RUN ["bash", "build.sh", "languagetool-standalone", "package", "-DskipTests"]

RUN unzip /languagetool/languagetool-standalone/target/LanguageTool-${LANGUAGE_TOOL_VERSION}.zip -d /dist

FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y \
        bash \
        libgomp1 \
        openjdk-8-jre-headless \
    && apt-get clean

ARG LANGUAGE_TOOL_VERSION

COPY --from=build /dist .

WORKDIR /LanguageTool-${LANGUAGE_TOOL_VERSION}

RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

COPY start.sh start.sh

COPY config.properties config.properties

CMD [ "bash", "start.sh" ]

EXPOSE 8010