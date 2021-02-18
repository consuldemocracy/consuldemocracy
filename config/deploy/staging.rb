set :branch, ENV["branch"] || :master

server deploysecret(:server), user: deploysecret(:user), roles: %w[web app db importer cron background]
