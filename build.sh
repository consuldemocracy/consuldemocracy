#!/bin/bash

TAG=maribor

sudo docker login rg.fr-par.scw.cloud/djnd -u nologin -p $SCW_SECRET_TOKEN

# BUILD AND PUBLISH PRAVNA MREZA
sudo docker build -f Dockerfile -t consul:$TAG .
sudo docker tag consul:$TAG rg.fr-par.scw.cloud/djnd/consul:$TAG
sudo docker push rg.fr-par.scw.cloud/djnd/consul:$TAG
