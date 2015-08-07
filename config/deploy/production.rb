set :deploy_to, deploysecret(:deploy_to)
set :branch, :production
set :ssh_options, port: deploysecret(:ssh_port)

server deploysecret(:server), user: deploysecret(:user), roles: %w(web app db importer)