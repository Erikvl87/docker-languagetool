#!/bin/bash

####################
##    Preamble    ##
####################
# Exit when any command fails.
set -e
# Only execute on the arm64 architecture.
if [[ $(dpkg --print-architecture) != "arm64" ]]; then
    echo "Not applying arm64 workaround: $(dpkg --print-architecture)"
    exit;
fi

echo "Applying arm64 workaround for BridJ."

# Make `wget` more robust by passing retry flags.
alias wget="wget --retry-connrefused --waitretry=30 --read-timeout=30 --timeout=30 --tries=20"

####################
##  BridJ setup   ##
####################
git clone http://github.com/nativelibs4java/BridJ.git
wget https://dyncall.org/r1.4/dyncall-1.4.tar.gz
tar xf dyncall-1.4.tar.gz
rm dyncall-1.4.tar.gz
mv dyncall-1.4 /BridJ/dyncall
cd /BridJ/dyncall
hg init
cd /BridJ

apt-get install -y default-jdk
mvn clean install -DskipTests -Dmaven.javadoc.skip=true -e

####################
##  BridJ build   ##
####################
cd /BridJ
./BuildNative -DFORCE_JAVA_HOME=/usr/lib/jvm/java-17-openjdk-arm64

####################
## Postprocessing ##
####################
cd /BridJ/target
mv bridj-0.8.0-SNAPSHOT.jar bridj.jar
unzip bridj.jar org/bridj/lib/linux_arm64/libbridj.so
cp -R org/bridj/lib/linux_arm64 org/bridj/lib/linux_x64
zip -d bridj.jar org/bridj/lib/linux_arm64
zip bridj.jar org/bridj/lib/linux_x64/libbridj.so
mv bridj.jar /dist/LanguageTool/libs/bridj.jar