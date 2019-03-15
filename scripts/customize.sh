#!/bin/sh
if [ -z "$CUSTOM_SET_NAME"]; then
    echo "CUSTOM_SET_NAME is not set"
else
    bin/rake db:migrate
    bin/rake db:seed
    echo $CUSTOM_SET_NAME
    curl -s "https://consul-assets-service.consulproject.nl/?set=$CUSTOM_SET_NAME&alpine=true" | sh
fi