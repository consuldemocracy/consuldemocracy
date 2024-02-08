#!/bin/bash

optOrArg=$1
argOrNone=$2

if [ "$optOrArg" = "-p" ]; then
  arg=$argOrNone
  production=true
else
  production=false
  arg=$optOrArg
fi

unamestr=$(uname)

if [ "$production" = true ]; then
  envfile=".env.production.${arg}"
else
  envfile=".env.${arg}"
fi

if [ "$unamestr" = 'Linux' ]; then
  export $(grep -v '^#' ${envfile} | xargs -d '\n')
elif [ "$unamestr" = 'FreeBSD' ] || [ "$unamestr" = 'Darwin' ]; then
  export $(grep -v '^#' ${envfile} | xargs -0)
fi

bin/tenant -a ${arg}

cd ./config
sed -e "s/xxx.xxx.xxx.xxx/$HOST/" -e "s/user: "deploy"/user: "$ANSIBLE_USER"/" deploy-secrets.yml.example > deploy-secrets.yml

echo "$REPO"

cap production deploy --trace
