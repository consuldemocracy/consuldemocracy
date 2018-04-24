bin/rake db:drop
bin/rake db:create
bin/rake db:migrate VERSION=20170513110025
psql cdj_development < doc/custom/extract_db_insert_180326.sql
bin/rake db:migrate
bin/rake db:seed
bin/rake db:custom_seed
bin/rake custom:finalize_db_import
