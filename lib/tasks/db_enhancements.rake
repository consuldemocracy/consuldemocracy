####### Important information ####################
# This file is used to setup a shared extensions #
# within a dedicated schema. This gives us the   #
# advantage of only needing to enable extensions #
# in one place.                                  #
#                                                #
# This task should be run AFTER db:create but    #
# BEFORE db:migrate.                             #
##################################################

namespace :db do
  desc "Also create shared_extensions Schema"
  task :extensions => :environment  do
    # Create Schema
    ActiveRecord::Base.connection.execute "CREATE SCHEMA IF NOT EXISTS shared_extensions;"
    # Enable plpgsql
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS plpgsql SCHEMA shared_extensions;"
    # Enable unaccent
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS unaccent SCHEMA shared_extensions;"
    # Enable pg_trgm
    ActiveRecord::Base.connection.execute "CREATE EXTENSION IF NOT EXISTS pg_trgm SCHEMA shared_extensions;"
    # Grant usage to public
    ActiveRecord::Base.connection.execute "GRANT usage ON SCHEMA shared_extensions to public;"
  end
end

Rake::Task["db:create"].enhance do
  Rake::Task["db:extensions"].invoke
end

Rake::Task["db:test:purge"].enhance do
  Rake::Task["db:extensions"].invoke
end
