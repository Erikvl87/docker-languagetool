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

# Workaround to make com.nativelibs4java:nativelibs4java-parent:pom:1.10-SNAPSHOT available as it is missing from Maven Central
# Requirement for BridJ build
git clone https://github.com/nativelibs4java/nativelibs4java.git
cd nativelibs4java && git checkout 1298fa36781605332746c42e2e3b9685aac1cdee
mvn clean install -DskipTests
cd /

# Workaround to make com.nativelibs4java:maven-velocity-plugin:jar:0.10-SNAPSHOT available as it is missing from Maven Central
# Requirement for BridJ build
git clone https://github.com/nativelibs4java/maven-velocity-plugin
cd maven-velocity-plugin && git checkout 9762c6d95c6440d8c49d0550720986f7acd3c489
mvn clean install -DskipTests
cd /

git clone http://github.com/nativelibs4java/BridJ.git
cd BridJ && git checkout 365792c16a4b5cbc7449e702a234d4e4494606a4
cd /
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