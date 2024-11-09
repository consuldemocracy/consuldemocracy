#! /bin/bash
# Author: Jean-Philippe.Prost@univ-amu.fr
# Creation: June 2024
# History of versions:
# - v1: (current)
#
#####
# deploy consuldemocracy with capistrano
# should be run the main app repo home dir, with:
# bin/custom/deploy-capistrano.sh
#####################

branch=master cap production deploy

# eof
