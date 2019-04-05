ARG LANGUAGETOOL_VERSION=4.5.1

FROM debian:stretch as build

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y \
        locales \
        bash \
        libgomp1 \
        openjdk-8-jdk-headless \
        git \
        maven \
        unzip \
    && apt-get clean

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8

ARG LANGUAGETOOL_VERSION

RUN git clone https://github.com/languagetool-org/languagetool.git --depth 1 -b v${LANGUAGETOOL_VERSION}

WORKDIR /languagetool

RUN ["mvn", "--projects", "languagetool-standalone", "--also-make", "package", "-DskipTests", "--quiet"]

RUN unzip /languagetool/languagetool-standalone/target/LanguageTool-${LANGUAGETOOL_VERSION}.zip -d /dist

FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y \
    && apt-get install -y \
        bash \
        libgomp1 \
        openjdk-8-jre-headless \
    && apt-get clean

ARG LANGUAGETOOL_VERSION

COPY --from=build /dist .

WORKDIR /LanguageTool-${LANGUAGETOOL_VERSION}

RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

COPY start.sh start.sh

COPY config.properties config.properties

RUN groupadd -r languagetool && useradd --no-log-init -r -g languagetool languagetool

USER languagetool

CMD [ "bash", "start.sh" ]

EXPOSE 8010