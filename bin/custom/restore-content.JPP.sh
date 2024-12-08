#! /bin/bash
# Author: Jean-Philippe.Prost@univ-amu.fr
# Creation: 31 May 2024
# History of versions:
# - v1: (current)
#
###########
# Restores the content data from a Consul backup archive created with the
# backup-content.sh utility, in a production environment.
# Make sure that the vars are the same as in the backup utility (especially the
# custom ones).
# Must be run from the backups/ folder on the local (development) host, after
# having run the installer in a fresh environment.
# Usage:
# $> ../restore-content.sh BACKUP_FILE
# where BACKUP_FILE should be named something like 
# consul-data.backup.XXXX.tar.gz and live in ./, with XXXX a timestamp.
#
# * IMPORTANT
# -[ ] READ BUG #1, below
# -[ ] As usual, THIS SCRIPT COMES WITH NO WARRANTY OF ANY KIND...
#
# * PREREQUISITES
# -[ ] Make sure to re-install the same version of the app as the one backed-up.
# Check the version.readme file in the backup tarball. 
# NOTE that although the
# installer and the main app are maintained with the same version number, it is
# likely that the installer has only been used once, and has not been kept 
# updated since. The version that matters is the main app's one.
# -[ ] Setup the new server, and update the config files on the local dev host
# accordingly. You may find helpful to rely on my own checklist to figure out
# your own: see CHECKLIST.setup. 
#
# * BUGS
# #1-[ ] after a single run, the site was displaying a 500 ERROR message.
# Re-running the script turned out fine. Go figure...
# -[ ] (no consequence): during backup, the attached files aren't copied with their relative
# path, as listed in the config var. Therefore, "config/" must be added
# at the end of the destination path. Both backup-content.sh and this script
# should be fixed simultaneously.
# -[ ] (no consequence): the 'linked_dirs' were backed up with the missing root folder 
# public/
#
# * TODO
# -[ ] recover the vars from backup-content.sh or somehow automate their
# consistency
# -[ ] take the list of paths where to restore the files directrly in the
# config file
# -[ ] make the psql/pg_restore command output in a log file. For some reason
# I can not make it work with psql, neither with the --output or --log-file, nor
# with a redirection command >>
##########

# INPUT ARGS
backup_tarball=$1

## REQUIRED CUSTOM VALUES
# The mother dir of the main app local repo:
CONSUL_INSTALL_HOME=/home/prost/CONSULaREC/consuldemocracy
# The user domain which hosts the (remote) server:
domain=construire.laroqueencommun.fr
# base path where to copy the backups on the local machine
# should NOT be a subdirectory of the main app local repo. Here, we place it
# in the repo's MOTHER directory:
local_backups_base_dir=$CONSUL_INSTALL_HOME/backups

## END REQUIRED CUSTOM VALUES

app_name=consul
env=production
deploy_user=deploy
database_name="$app_name"_"$env"
database_user="$deploy_user"
database_password="$deploy_user"
database_hostname="localhost"

## OTHER VARS
# specific vars, not found in group_vars/all

# shortcuts to main app paths (needed for saving the user attachments)
consul_shared_path=/home/"$deploy_user"/"$app_name"/shared

# extracts the backup's TIMESTAMP
tmp=${backup_tarball/".tar.gz"}
TIMESTAMP=${tmp/"$app_name-data.backup."}
# work out the dump file name
dump_file="$database_name"_db.dump.$TIMESTAMP.sql

###########################################################################

## SCP THE BACKUP TARBALL FROM THE LOCAL DEV HOST TO THE REMOTE PRODUCTION HOST
scp "$backup_tarball" "$deploy_user@$domain:~/"

## SSH the server without var def
ssh -T "$deploy_user@$domain" << EOF 
if  [ ! -d tmp ]; then
  mkdir tmp
fi
mv $backup_tarball tmp

## UN-TAR THE BACKUP ARCHIVE
cd tmp; tar xzf "$backup_tarball"; cd

# create tmp symlinks
ln -s "$consul_shared_path" ~/consul_shared

EOF

#####
## RESTORE THE USER ATTCHMENTS FILES

# The full list of files and folders that might be affected is in 
# consul/current/config/deploy.rb (linked_files and linked_dirs). All of them 
# but the tmp folder are included in the backup as a tar file.
# All the paths are relative to ~deploy/consul/shared

# List of files and folders:
# set :linked_files, %w[config/database.yml config/secrets.yml]
# set :linked_dirs, %w[.bundle log tmp public/system public/assets
#                     public/ckeditor_assets public/machine_learning/data storage]
##
## SSH the remote server, with var def allowed
ssh -T "$deploy_user@$domain" << 'EOF' 

# BUG: the real values are the commented ones, same as in backup-content.sh
#linked_files=( config/database.yml config/secrets.yml )
linked_files=( database.yml secrets.yml )
# BUG: the real values are the commented ones, same as in backup-content.sh
#linked_dirs=( .bundle log public/system public/assets public/ckeditor_assets public/machine_learning/data storage )
# BUG workarounds
linked_dirs1=( .bundle log storage )
linked_dirs2=( system assets ckeditor_assets )
linked_dirs3=( data )

# -[ ] BUG (workaround): during backup, the attached files aren't copied with
# their relative path, as listed in the config var. Therefore, "config/" must be
# added at the end of the destination path. Both the backup and restore scripts
# should be fixed simultaneously.
#
# copy the linked files
for file in "${linked_files[@]}"; do
  cp ~/tmp/backup_tmp/$file ~/consul_shared/config
done

# copy the linked dirs
# -[ ] BUG (workaround1)
for dir in "${linked_dirs1[@]}"; do
  cp -r ~/tmp/backup_tmp/$dir ~/consul_shared
done  

# -[ ] BUG (workaround2)
#copy the linked dirs
for dir in "${linked_dirs[@]}"; do
  cp -r --copy-contents --dereference ~/tmp/backup_tmp/$dir ~/consul_shared/public
done  

# -[ ] BUG (workaround3)
#copy the linked dirs
for dir in "${linked_dirs[@]}"; do
  cp -r --copy-contents --dereference ~/tmp/backup_tmp/$dir ~/consul_shared/public/machine_learning
done  

EOF

############################################"
## SSH the server without var def
ssh -T "$deploy_user@$domain" << EOF 

## RESTORE THE POSTGRES DB
# Reminder of the pg_dump command:
####pg_dump --username="$deploy_user" --no-password --dbname="$database_name" --file="$output_dump_file"
#
# create a temporary .pgpass file to store the database_password
# The file must contain a line formatted as follows:
# hostname:port:database:username:password
echo "$database_hostname::$database_name:$database_user:$database_password" > ~/.pgpass

# The permissions on a password file must disallow any access to world or group
chmod 0600 ~/.pgpass

# What should be (see backup-content.sh TODO-list item to adapt the pg_dump
# command):
# run the postgres restoration utility
#pg_restore --username="$deploy_user" --no-password --dbname="$database_name" tmp/backup_tmp/$dump_file
# run psql with the sql dump file
psql --username="$deploy_user" --no-password --dbname="$database_name" --file=tmp/backup_tmp/$dump_file

## HOUSEKEEPING
# remove the db pass file
rm ~/.pgpass

# remove the symlinks
rm ~/consul_shared

# remove the tmp restoration dir
rm -rf tmp

EOF

# eof
