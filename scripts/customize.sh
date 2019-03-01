#!/bin/sh
if [[ -v CUSTOM_SET_NAME ]]; then
    bin/rake db:migrate
    bin/rake db:seed
    curl -s https://consul-assets-service.consulproject.nl/?set=$CUSTOM_SET_NAME&alpine=true | sh
fi