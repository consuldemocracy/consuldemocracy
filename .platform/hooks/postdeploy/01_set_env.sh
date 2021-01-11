#!/bin/bash

#Create a copy of the environment variable file
cp /opt/elasticbeanstalk/deployment/env /opt/elasticbeanstalk/deployment/custom_env_var

#Set permissions to the custom_env_var file so this file can be accessed by any user on the instance. You can restrict permissions as per your requirements.
chmod 644 /opt/elasticbeanstalk/deployment/custom_env_var

#Remove duplicate files upon deployment
rm -f /opt/elasticbeanstalk/deployment/*.bak
