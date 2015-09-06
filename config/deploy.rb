# config valid only for current version of Capistrano
lock '3.4.0'

def deploysecret(key)
  @deploy_secrets_yml ||= YAML.load_file('config/deploy-secrets.yml')[fetch(:stage).to_s]
  @deploy_secrets_yml[key.to_s]
end


set :rails_env, fetch(:stage)
set :rvm_ruby_version, '2.2.3'
set :rvm_type, :user

set :application, 'participacion'
set :full_app_name, deploysecret(:full_app_name)

set :server_name, deploysecret(:server_name)
#set :repo_url, 'git@github.com:AyuntamientoMadrid/participacion.git'
# If ssh access is restricted, probably you need to use https access
set :repo_url, 'https://github.com/AyuntamientoMadrid/participacion.git'

set :scm, :git
set :revision, `git rev-parse --short #{fetch(:branch)}`.strip

set :log_level, :info
set :pty, true
set :use_sudo, false

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{log tmp public/system public/assets}

set :keep_releases, 5

set :local_user, ENV['USER']

# Run test before deploy
set :tests, ["spec"]

set :delayed_job_workers, 2

# Config files should be copied by deploy:setup_config
set(:config_files, %w(
  log_rotation
  database.yml
  secrets.yml
  unicorn.rb
  sidekiq.yml
))

namespace :deploy do
  # Check right version of deploy branch
  # before :deploy, "deploy:check_revision"
  # Run test aund continue only if passed
  # before :deploy, "deploy:run_tests"

  # Custom compile and rsync of assets - works, but it is very slow
  #after 'deploy:symlink:shared', 'deploy:compile_assets_locally'

  after :finishing, 'deploy:beta_testers'
  after :finishing, 'deploy:cleanup'
  # Restart unicorn
  after 'deploy:publishing', 'deploy:restart'
  # Restart Delayed Jobs
  after 'deploy:published', 'delayed_job:restart'
end
