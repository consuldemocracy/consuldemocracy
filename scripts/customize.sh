#!/bin/bash
if [[ -v CUSTOM_SET_NAME ]]; then
    bin/rake db:setup
    curl -s https://consul-assets-service.consulproject.nl/?set=$CUSTOM_SET_NAME | bash
fi