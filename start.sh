#!/bin/bash

for varname in ${!langtool_*}
do
  config_injected=true
  echo "${varname#'langtool_'}="${!varname} >> config.properties
done

echo "fasttextModel=/fastText/lid.176.bin" >> config.properties
echo "fasttextBinary=$(which fasttext)" >> config.properties

if [ "$config_injected" = true ] ; then
  echo 'The following configuration is passed to LanguageTool:'
  cat config.properties
fi

Xms=${Java_Xms:-256m}
Xmx=${Java_Xmx:-512m}

PRIO_ARGS=(  
  "-Xms$Xms"
  "-Xmx$Xmx"
)

if [ -f /LanguageTool/logback.xml ] ; then
  PRIO_ARGS+=("-Dlogback.configurationFile=/LanguageTool/logback.xml")
fi

LT_ARGS=(
  -cp languagetool-server.jar
  org.languagetool.server.HTTPServer
  --port 8010
  --public
  --allow-origin '*'
  --config config.properties
)

set -x
exec java "${PRIO_ARGS[@]}" "${LT_ARGS[@]}"
