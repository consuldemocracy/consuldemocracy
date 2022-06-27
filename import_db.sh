#!/bin/bash

# EDIT DATABASE NAME TO CHOOSE WHICH ONE YOU WANT
DATABASE_NAME="consul_maribor"

# DATABASE PASSWORD IS DYNAMICALLY RETRIEVED FROM THE CLUSTER
DATABASE_PASSWORD=$(kubectl get secret postgresql -n shared -o jsonpath="{.data.postgresql-password}" | base64 --decode)

echo
echo "PORT FORWARDING"
nohup kubectl port-forward pod/postgresql-0 54321:5432 --namespace=shared &>/dev/null &

# store the kubectl pid for later
KUBECTL_PID=$!

# wait for port forwarding to initialise
sleep 5

echo
echo "DUMPING DATABASE TO db.dump"
PGPASSWORD=$DATABASE_PASSWORD \
    pg_dump -U postgres \
        -f db.dump \
        -d "$DATABASE_NAME" \
        -p 54321 \
        -h localhost

echo
echo "DROPPING THE DB VOLUME"
sudo docker-compose down -v
sudo docker-compose up -d

sleep 5

echo
echo "LOADING DB INTO CONTAINER"
sudo docker container exec -i $(sudo docker-compose ps -q database) psql -U postgres consul < db.dump

sudo docker-compose down

echo "STOPPING PORT FORWARDING"
kill $KUBECTL_PID

echo
echo "ALL DONE, YOU CAN RUN docker-compose up AND/OR DELETE db.dump"
