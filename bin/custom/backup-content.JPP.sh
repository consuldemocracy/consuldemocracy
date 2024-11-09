#! /bin/bash
# Author: Jean-Philippe.Prost@univ-amu.fr
# Creation: 21 May 2024
# History of versions:
# - v1: (current)
#
###########################################################################
# Backs up the app content data in a production environment:
#  (a) dumps the PostgreSQL database (single user, single db)
#  (b) saves the user-attached documents
#  (c) creates a single output tarball with both the dump and the attachments
#  (d) copies the tarball to the local host
################ 
#### * PRE-REQUISITES
#  - Must be run from the LOCAL host, which is assumed to be already set up for
# key-based SSH connections (i.e., without credentials) to the remote server. It
# should be the case if the consuldemocracy installer was used to install the 
# app.
#  - The script assumes that the installer/ and the consuldemocracy/ directories
# are siblings of the custom directory in var CONSUL_INSTALL_HOME. That is, this
# script must be run from the installer's parent directory on the local host.
#  - Some values, annotated "REQUIRED CUSTOM VALUES", must be customised for the
# running environment.
#
#### * KNOWN BUGS
# -[ ] (no consequence): the attached files aren't copied with their relative path: should 
# add config/ at the end of the destination path. restore-content.sh also
# affected.
# -[ ] (no consequence): the 'linked_dirs' were backed up with the missing root folder 
# public/
#
#################
#### * TODO
# -[ ] get the main var values directly from group_vars/all
#   -[ ] in particular, externalize the database user and pwd
# -[ ] get the values of linked_files and linked_dirs directly from 
# consul/current/config/deploy.rb, instead of hard-coding them here. 
# The problem is: the linked_dirs var takes 2 lines to list all the values,
# which makes it more tricky to extract with simply a grep command. a sed
# command should do it.
# -[ ] modify the pg_dump command to make it output a file in an "alternative
# format", suitable for use with pg_restore instead of psql. Most likely, add
# the option: --format=plain
# Then adapt restore-content.sh accordingly.
# -[ ] add suggested instruction to be copied in the crontab
###########################################################################
#
# I. VAR DEFINITIONS
#
## I.1 GLOBAL VARS SHARED WITH THE APP
#-------------------------------------
#
# the following values are needed, and must be customised according to the running environment.
# The var without default values are annotated "REQUIRED CUSTOM VALUES". The 
# other ones use the same default values as in the app wherever possible.
# The values can be found in the installer config file group_vars/all as the following strings (without the hash character), and should be reproduced here consistently (at least for the deploy/database user, which must be identical):
# domain: construire.laroqueencommun.fr
# app_name: consul
# env: production
# deploy_user: deploy
# database_name: "{{app_name}}_{{ env }}"
# database_user: "{{ deploy_user }}"
# database_password: "{{ deploy_user }}"
# database_hostname: "localhost"

### I.1.1 REQUIRED CUSTOM VALUES
#-------------------------------
# The mother dir of the main app local repo:
CONSUL_INSTALL_HOME=/home/prost/CONSULaREC/consuldemocracy
# The user domain which hosts the (remote) server:
domain=construire.laroqueencommun.fr
# base path where to copy the backups on the local machine
# should NOT be a subdirectory of the main app local repo. Here, we place it
# in the repo's MOTHER directory:
local_backups_base_dir=$CONSUL_INSTALL_HOME/backups
## END REQUIRED CUSTOM VALUES

### I.1.2 VARS WITH DEFAULT VALUES COPIED AND PASTED FROM goup_vars/all
#----------------------------------------------------------------------
app_name=consul
env=production
deploy_user=deploy
database_name="$app_name"_"$env"
database_user="$deploy_user"
database_password="$deploy_user"
database_hostname="localhost"

## I.2 OTHER VARS
#----------------
# specific vars, not found in group_vars/all
#
# base path where to store the backups on the remote server
remote_backups_base_dir=/home/"$deploy_user"/backups

# shortcuts to main app paths (needed for saving the user attachments)
consul_shared_path=/home/"$deploy_user"/"$app_name"/shared

### OUTPUT FILES AND DIRS
#------------------------
# timestamp for this backup session
TIMESTAMP=`date +%Y%m%d%H%M`
# the remote tmp dir for this backup session
remote_this_backup_tmp_dir="$remote_backups_base_dir/$TIMESTAMP"
# the output dump file name and its remote path
output_dump_file=$remote_this_backup_tmp_dir/"$database_name"_db.dump.$TIMESTAMP.sql
#the output backup tarball name
output_tarball="$app_name-data.backup.$TIMESTAMP.tar"

###########################################################################
# II. BACKUP PROCESS

echo
echo "Backing up Consul Democracy..."
echo

cd $CONSUL_INSTALL_HOME

#####
##### CHECK THE INSTALLED VERSION
#####
# Info: the -C <path>  option runs as if git was started in <path> instead of the current working directory.
# Note that the version numbers should be the same between the installer and the
# main app. Yet, if the installer is not up to date at the time of running this
# script, which is likely to be the case when the app has been installed for a
# while, there might be a discrepancy between the version numbers of the main
# app and of the installer. In that case, it is better to rely on the main app's
# version.
#VERSION=$(git -C installer/ describe --tags)
VERSION=$(git -C consuldemocracy/ describe --tags)
echo "The main app is currently at version $VERSION"

#####
##### SSH THE REMOTE HOST (without var def) #####
#####
# The login name must be the same as the db user, or you will get a "Peer authentication failed for user" error from Postgres
echo "connecting the remote server with $deploy_user@$domain ..."
echo
ssh -T "$deploy_user@$domain" << EOF 

# check if the remote destination directory exists; if not, create it
if  [ ! -d "$remote_backups_base_dir" ]; then
  mkdir "$remote_backups_base_dir"
fi
if  [ ! -d "$remote_this_backup_tmp_dir" ]; then
  mkdir "$remote_this_backup_tmp_dir"
fi

#####
##### DUMP THE DB #####

# create a temporary .pgpass file to store the database_password
# The file must contain a line formatted as follows:
# hostname:port:database:username:password
echo "$database_hostname::$database_name:$database_user:$database_password" > ~/.pgpass

# The permissions on a password file must disallow any access to world or group
chmod 0600 ~/.pgpass

# dump the db as a plain sql script file
pg_dump --username="$deploy_user" --no-password --dbname="$database_name" --file="$output_dump_file"

# remove the pg password file
rm ~/.pgpass

# for the next commands to be run on the remote server we will need to define
# variables, which requires special syntax (see How to execute commands remotely
# using SSH).
# In order to avoid redundancy with some of the vars already defined,
# and to limit the number of required variable definitions on the server to the
# minimum, we create symbolic links for the path variables that we need.

# create symlinks, to be used by the next set of SSH commands
ln -s $remote_this_backup_tmp_dir ~/backup_tmp
ln -s $consul_shared_path ~/consul_shared
EOF

#####
##### SAVE THE FILES ATTACHED BY USERS #####
#####
# SSH the remote server, allowing the definition of variables
ssh -T "$deploy_user@$domain" << 'EOF' 

# The full list of files and folders that might be affected is in 
# consul/current/config/deploy.rb (linked_files and linked_dirs). All of them 
# but the tmp folder are included in the backup as a tar file.
# All the paths are relative to ~deploy/consul/shared

# List of files and folders:
# set :linked_files, %w[config/database.yml config/secrets.yml]
# set :linked_dirs, %w[.bundle log tmp public/system public/assets
#                     public/ckeditor_assets public/machine_learning/data storage]

linked_files=( config/database.yml config/secrets.yml )
linked_dirs=( .bundle log public/system public/assets public/ckeditor_assets public/machine_learning/data storage )

# -[ ] BUG: files aren't copied with their relative path: should add config/
# at the end of the destination path. restore-content.sh also affected
# copy the linked files
for file in "${linked_files[@]}"; do
  cp ~/consul_shared/$file ~/backup_tmp
done

#copy the linked dirs
for dir in "${linked_dirs[@]}"; do
  cp -r --copy-contents --dereference ~/consul_shared/$dir ~/backup_tmp
done  

# disconnect the remote host
EOF

###
### SSH the server without var def
###
ssh -T "$deploy_user@$domain" << EOF 

# create a tarball of the db dump and all the linked documents
# Note that we can not zip the tarball yet, since next we need to append a text
# file with the version tag (this operation is not allowed on a zipped tarball).
cd; tar -cf "backups/$output_tarball" --dereference backup_tmp

## add version text file to the local tarball
echo "$VERSION" >> ~/backup_tmp/version.readme
tar --append -f "backups/$output_tarball" ~/backup_tmp/version.readme

## compress the tarball
gzip "backups/$output_tarball"

#### HOUSEKEEPING #####
# remove the symlinks
rm backup_tmp ~/consul_shared

# remove the tmp backup dir
rm -rf "$remote_this_backup_tmp_dir"

# disconnect the remote host
EOF

#####
##### BACK ON THE LOCAL MACHINE

# check if the local destination directory exists; if not, create it
if [ ! -d "$local_backups_base_dir" ]; then
  mkdir "$local_backups_base_dir"
fi

## copy the backup tarball to the local host
echo copying the backup tarball to the local host:
scp "$deploy_user@$domain:~/backups/$output_tarball.gz" "$local_backups_base_dir"

# eof
