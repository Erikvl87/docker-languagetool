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

RUN ["mvn", "--projects", "languagetool-standalone", "--also-make", "package", "-DskipTests", "--quiet"]

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

RUN groupadd -r languagetool && useradd --no-log-init -r -g languagetool languagetool

USER languagetool

CMD [ "bash", "start.sh" ]

EXPOSE 8010