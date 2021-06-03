#!/bin/bash

# exit when any command fails.
set -e

# Only execute on the arm64 architecture.
if [[ $(dpkg --print-architecture) != "arm64" ]]; then
    exit;
fi

unzip /dist/LanguageTool/libs/hunspell.jar -d /hunspell_jar
mkdir -p /hunspell_jar/org/bridj/lib/linux_aarch64
cd /hunspell_jar
cp /usr/lib/aarch64-linux-gnu/libhunspell* /hunspell_jar/org/bridj/lib/linux_aarch64
cp /usr/lib/aarch64-linux-gnu/libhunspell* /hunspell_jar/org/bridj/lib/linux_x64
zip -r hunspell.jar dumonts META-INF/ org/
cp hunspell.jar /dist/LanguageTool/libs/hunspell.jar
