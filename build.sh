#!/bin/bash

sudo docker login rg.fr-par.scw.cloud/djnd -u nologin -p $SCW_SECRET_TOKEN

# BUILD AND PUBLISH PRAVNA MREZA
sudo docker build -f Dockerfile -t consul:latest .
sudo docker tag consul:latest rg.fr-par.scw.cloud/djnd/consul:latest
sudo docker push rg.fr-par.scw.cloud/djnd/consul:latest
