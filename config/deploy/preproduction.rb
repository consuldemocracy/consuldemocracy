set :branch, :"development-valladolid"

ask(:password, nil, echo: false)

server deploysecret(:server1), user: deploysecret(:user), password: fetch(:password), roles: %w[web app db importer cron background]
# server deploysecret(:server2), user: deploysecret(:user), roles: %w[web app db importer]
