set :branch, ENV["branch"] || :master

server main_deploy_server, user: deploysecret(:user), roles: %w[web app db importer cron background]
