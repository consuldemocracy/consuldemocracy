# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

require "capistrano/bundler"
require "capistrano/rails/assets"
require "capistrano/rails/migrations"
#require "capistrano/passenger"
require "capistrano/delayed_job"
require "whenever/capistrano"
require "rvm1/capistrano3"

require "capistrano/puma"
install_plugin Capistrano::Puma, load_hooks: false
install_plugin Capistrano::Puma::Daemon

#SCM: Git
require "capistrano/scm/git"
install_plugin Capistrano::SCM::Git

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }
Dir.glob("lib/capistrano/tasks/*.cap").each { |r| import r }
Dir.glob("lib/capistrano/**/*.rb").each { |r| import r }
