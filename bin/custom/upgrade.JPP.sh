#! /bin/bash
# Author: Jean-Philippe.Prost@univ-amu.fr
# Creation: 9 Nov 2024
# History of versions:
# - v1: (current)
#
###########################################################################
# Upgrades to new release of the main app.
# Takes the release number (i.e. tag) as input argument (required).
# Should be run from the local repo home dir with:
# bin/custom/upgrade.sh
###################################################

# Check input args
if [ $# -eq 0 ]
  then
    echo "FAIL: release tag required"
    exit 0
fi

RELEASE=$1

echo "upgrading the Consul Democracy main app to release $RELEASE..."
echo

# upgrading
git checkout master
git pull
git checkout -b release
git fetch upstream tag $RELEASE
git merge $RELEASE
git checkout master
git merge -m "merge release $RELEASE" --no-edit release
git branch -d release
git push

# Trick to force rvm to output on stdout when a new version of ruby is required
CURRENT=$PWD
cd..
cd $CURRENT

# since the Ruby version has changed, capistrano should likely be updated too:
gem install capistrano
bundle install

# deploy with capistrano
# branch=master cap production deploy
echo
echo "DO NOT forget to deploy the app with capistrano."
echo "For that you can run bin/custom/deploy-capistrano.sh"

#eof
