#!/bin/bash

# exit when any command fails.
set -e

# Only execute on the arm64 architecture.
if [[ $(dpkg --print-architecture) != "arm64" ]]; then
    exit;
fi

apt-get install -y \
    build-essential \
    libhunspell-dev \
    mercurial \
    wget \
    zip \
    && apt-get clean

cd /
export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-arm64"
git clone https://github.com/nativelibs4java/BridJ
cd /BridJ
git apply ../bridj.patch
wget https://dyncall.org/r1.1/dyncall-1.1.tar.gz
tar xf dyncall-1.1.tar.gz
rm dyncall-1.1.tar.gz
mv dyncall-1.1 dyncall
cd /BridJ/dyncall
hg init
cd /BridJ
./BuildNative
mvn clean install -DskipTests -Dmaven.install.skip=true -e

mkdir rezip
cd /BridJ/rezip
cp ../target/bridj-0.7.1-SNAPSHOT.jar .
unzip bridj-0.7.1-SNAPSHOT.jar
rm bridj-0.7.1-SNAPSHOT.jar
cd /BridJ/rezip/org/bridj/lib/
cp linux_aarch64/libbridj.so linux_x64/
cd /BridJ/rezip
zip -r bridj.jar META-INF/ org/
cp bridj.jar /dist/LanguageTool/libs/bridj.jar
