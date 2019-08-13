[![Build Status](https://travis-ci.org/Erikvl87/docker-languagetool.svg?branch=master)](https://travis-ci.org/Erikvl87/docker-languagetool) [![Docker Pulls](https://img.shields.io/docker/pulls/erikvl87/languagetool)](https://hub.docker.com/r/erikvl87/languagetool)

# Dockerfile for LanguageTool
This repository contains a Dockerfile to create a Docker image for [LanguageTool](https://github.com/languagetool-org/languagetool).

 [LanguageTool](https://www.languagetool.org/) is an Open Source proofreading software for English, French, German, Polish, Russian, and [more than 20 other languages](https://languagetool.org/languages/). It finds many errors that a simple spell checker cannot detect.

# Usage

## Using Docker Hub
```
docker pull erikvl87/languagetool
docker run --rm -p 8010:8010 erikvl87/languagetool
```

This will pull the `latest` tag from Docker Hub. Optionally, specify a [tag](https://hub.docker.com/r/erikvl87/languagetool/tags) to pin onto a fixed version. These versions are derived from the official LanguageTool releases. Updates to the Dockerfile for already published versions are released with the `dockerupdate-X` postfix in the tag.

## Using the Dockerfile
```
git clone https://github.com/Erikvl87/docker-languagetool.git
docker build -t languagetool .
docker run --rm -it -p 8010:8010 languagetool
```

## HTTPServerConfig
You are able to use the [HTTPServerConfig](https://languagetool.org/development/api/org/languagetool/server/HTTPServerConfig.html) configuration options by prefixing the fields with `langtool_` and setting them as [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file).

## Heap size
LanguageTool will be started with a minimal heap size (`-Xms`) of `256m` and a maximum (`-Xmx`) of `512m`. You can overwrite these defaults by setting the [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) `Java_Xms` or `Java_Xmx`.