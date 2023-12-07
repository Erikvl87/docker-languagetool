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

echo "Applying arm64 workaround for Hunspell."

# Make `wget` more robust by passing retry flags.
alias wget="wget --retry-connrefused --waitretry=30 --read-timeout=30 --timeout=30 --tries=20"
# Dependencies should be satisfied by `bridj.sh`.

##############################
## Replace `libhunspell.so` ##
##############################
mkdir /hunspell
cd /hunspell
wget https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/libhunspell-1.7.2-r3.apk
tar --warning=no-unknown-keyword -xzf libhunspell-1.7.2-r3.apk
mkdir -p /hunspell/org/bridj/lib/linux-aarch64/
mv /hunspell/usr/lib/libhunspell-1.7.so.0.0.1 /hunspell/org/bridj/lib/linux-aarch64/libhunspell.so
cd /hunspell/org/bridj/lib/
zip /dist/LanguageTool/libs/hunspell.jar linux-aarch64/libhunspell.so