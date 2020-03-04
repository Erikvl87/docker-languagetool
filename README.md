[![Build Status](https://github.com/Erikvl87/docker-languagetool/workflows/Build/badge.svg)](https://github.com/Erikvl87/docker-languagetool) [![Tests Status](https://github.com/Erikvl87/docker-languagetool/workflows/Tests/badge.svg)](https://github.com/Erikvl87/docker-languagetool) [![Docker Pulls](https://img.shields.io/docker/pulls/erikvl87/languagetool)](https://hub.docker.com/r/erikvl87/languagetool) [![Latest GitHub tag](https://img.shields.io/github/v/tag/Erikvl87/docker-languagetool?label=GitHub%20tag)](https://github.com/Erikvl87/docker-languagetool/releases)

# Dockerfile for LanguageTool
This repository contains a Dockerfile to create a Docker image for [LanguageTool](https://github.com/languagetool-org/languagetool).

> [LanguageTool](https://www.languagetool.org/) is an Open Source proofreading software for English, French, German, Polish, Russian, and [more than 20 other languages](https://languagetool.org/languages/). It finds many errors that a simple spell checker cannot detect.

# Setup

## Setup using Docker Hub
```
docker pull erikvl87/languagetool
docker run --rm -p 8010:8010 erikvl87/languagetool
```

This will pull the `latest` tag from Docker Hub. Optionally, specify a [tag](https://hub.docker.com/r/erikvl87/languagetool/tags) to pin onto a fixed version. These versions are derived from the official LanguageTool releases. Updates to the Dockerfile for already published versions are released with a `-dockerupdate-{X}` postfix in the tag (where `{X}` is an incremental number).

## Setup using the Dockerfile
This approach could be used when you plan to make changes to the `Dockerfile`.
```
git clone https://github.com/Erikvl87/docker-languagetool.git --config core.autocrlf=input
docker build -t languagetool .
docker run --rm -it -p 8010:8010 languagetool
```

# Configuration

## Java heap size
LanguageTool will be started with a minimal heap size (`-Xms`) of `256m` and a maximum (`-Xmx`) of `512m`. You can overwrite these defaults by setting the [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file) `Java_Xms` and `Java_Xmx`.

An example startup configuration:
```
docker run --rm -it -p 8010:8010 -e Java_Xms=512m -e Java_Xmx=2g erikvl87/languagetool
```

## LanguageTool HTTPServerConfig
You are able to use the [HTTPServerConfig](https://languagetool.org/development/api/org/languagetool/server/HTTPServerConfig.html) configuration options by prefixing the fields with `langtool_` and setting them as [environment variables](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file).

An example startup configuration:
```
docker run --rm -it -p 8010:8010 -e langtool_pipelinePrewarming=true -e Java_Xms=1g -e Java_Xmx=2g erikvl87/languagetool
```

## Using n-gram datasets
> LanguageTool can make use of large n-gram data sets to detect errors with words that are often confused, like __their__ and __there__.

*Source: [http://wiki.languagetool.org/finding-errors-using-n-gram-data](http://wiki.languagetool.org/finding-errors-using-n-gram-data)*

[Download](http://languagetool.org/download/ngram-data/) the n-gram dataset(s) to your local machine and mount the local n-gram data directory to the `/ngrams` directory in the Docker container [using the `-v` configuration](https://docs.docker.com/engine/reference/commandline/run/#mount-volume--v---read-only) and set the `languageModel` configuration to the `/ngrams` folder.

An example startup configuration:
```
docker run --rm -it -p 8010:8010 -e langtool_languageModel=/ngrams -v local/path/to/ngrams:/ngrams erikvl87/languagetool
```

# Usage
By default this image is configured to listen on port 8010 which diviates from the default port of LanguageTool 8081.

An example cURL request:
```
curl --data "language=en-US&text=a simple test" http://localhost:8010/v2/check
```

Please refer to the official LanguageTool documentation for further usage instructions.
