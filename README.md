[![Build Status](https://github.com/Erikvl87/docker-languagetool/workflows/Build/badge.svg)](https://github.com/Erikvl87/docker-languagetool) [![Tests Status](https://github.com/Erikvl87/docker-languagetool/workflows/Tests/badge.svg)](https://github.com/Erikvl87/docker-languagetool) [![Docker Pulls](https://img.shields.io/docker/pulls/erikvl87/languagetool)](https://hub.docker.com/r/erikvl87/languagetool) [![Latest GitHub tag](https://img.shields.io/github/v/tag/Erikvl87/docker-languagetool?label=GitHub%20tag)](https://github.com/Erikvl87/docker-languagetool/releases)

# Dockerfile for LanguageTool
This repository contains a Dockerfile to create a Docker image for [LanguageTool](https://github.com/languagetool-org/languagetool).

 [LanguageTool](https://www.languagetool.org/) is an Open Source proofreading software for English, French, German, Polish, Russian, and [more than 20 other languages](https://languagetool.org/languages/). It finds many errors that a simple spell checker cannot detect.

# Usage

## Using Docker Hub
```
docker pull erikvl87/languagetool
docker run --rm -p 8010:8010 erikvl87/languagetool
```

This will pull the `latest` tag from Docker Hub. Optionally, specify a [tag](https://hub.docker.com/r/erikvl87/languagetool/tags) to pin onto a fixed version. These versions are derived from the official LanguageTool releases. Updates to the Dockerfile for already published versions are released with a `-dockerupdate-{X}` postfix in the tag (where `{X}` is an incremental number).

## Using the Dockerfile
```
git clone https://github.com/Erikvl87/docker-languagetool.git --config core.autocrlf=input
docker build -t languagetool .
docker run --rm -it -p 8010:8010 languagetool
```

## HTTPServerConfig
You are able to use the [HTTPServerConfig](https://languagetool.org/development/api/org/languagetool/server/HTTPServerConfig.html) configuration options by prefixing the fields with `langtool_` and setting them as [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file).

## Heap size
LanguageTool will be started with a minimal heap size (`-Xms`) of `256m` and a maximum (`-Xmx`) of `512m`. You can overwrite these defaults by setting the [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) `Java_Xms` or `Java_Xmx`.