set :deploy_to, -> { deploysecret(:deploy_to) }
set :server_name, deploysecret(:server_name)
set :db_server, deploysecret(:db_server)
set :branch, deploysecret(:branch, ENV['branch']) || :master
set :stage, :staging
set :rails_env, deploysecret(:rails_env, 'staging').to_sym

server deploysecret(:server), user: deploysecret(:user), roles: %w(web app db importer cron)

