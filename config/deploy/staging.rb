set :branch, ENV["branch"] || :master

ask(:password, nil, echo: false)

server deploysecret(:server), user: deploysecret(:user), password: fetch(:password), roles: %w[web app db importer cron]
