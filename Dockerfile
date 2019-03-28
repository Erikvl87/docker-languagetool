FROM debian:stretch

RUN set -ex \
    && mkdir -p /uploads /etc/apt/sources.list.d /var/cache/apt/archives/ \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get clean \
    && apt-get update -y \
    && apt-get install -y \
        bash \
        openjdk-8-jre-headless \
        unzip

ENV VERSION 4.5
ADD https://www.languagetool.org/download/LanguageTool-$VERSION.zip /LanguageTool-$VERSION.zip

RUN unzip LanguageTool-$VERSION.zip \
    && rm LanguageTool-$VERSION.zip

WORKDIR /LanguageTool-$VERSION

RUN mkdir /nonexistent && touch /nonexistent/.languagetool.cfg

CMD [ "java", "-cp", "languagetool-server.jar", "org.languagetool.server.HTTPServer", "--port", "8010", "--public", "--allow-origin", "'*'" ]
EXPOSE 8010