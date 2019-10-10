# config valid only for current version of Capistrano
lock "~> 3.10.1"

def deploysecret(key)
  @deploy_secrets_yml ||= YAML.load_file("config/deploy-secrets.yml")[fetch(:stage).to_s]
  @deploy_secrets_yml.fetch(key.to_s, "undefined")
end

set :rails_env, fetch(:stage)
set :rvm1_ruby_version, "2.3.2"

set :application, "consul"
set :full_app_name, deploysecret(:full_app_name)

set :server_name, deploysecret(:server_name)
set :repo_url, "https://github.com/consul/consul.git"

set :revision, `git rev-parse --short #{fetch(:branch)}`.strip

set :log_level, :info
set :pty, true
set :use_sudo, false

set :linked_files, %w[config/database.yml config/secrets.yml config/environments/production.rb]
set :linked_dirs, %w[log tmp public/system public/assets public/ckeditor_assets]

set :keep_releases, 5

set :local_user, ENV["USER"]

set :delayed_job_workers, 2
set :delayed_job_roles, :background

set(:config_files, %w[
  log_rotation
  database.yml
  secrets.yml
])

set :whenever_roles, -> { :app }

namespace :deploy do
  #before :starting, "rvm1:install:rvm"  # install/update RVM
  #before :starting, "rvm1:install:ruby" # install Ruby and create gemset
  #before :starting, "install_bundler_gem" # install bundler gem

  after "deploy:migrate", "add_new_settings"
  after :publishing, "deploy:restart"
  after :published, "delayed_job:restart"
  after :published, "refresh_sitemap"

  after :finishing, "deploy:cleanup"

  desc "Deploys and runs the tasks needed to upgrade to a new release"
  task :upgrade do
    after "add_new_settings", "execute_release_tasks"
    invoke "deploy"
  end
end

task :install_bundler_gem do
  on roles(:app) do
    execute "rvm use #{fetch(:rvm1_ruby_version)}; gem install bundler"
  end
end

task :refresh_sitemap do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, "sitemap:refresh:no_ping"
      end
    end
  end
end

task :add_new_settings do
  on roles(:db) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, "settings:add_new_settings"
      end
    end
  end
end

task :execute_release_tasks do
  on roles(:app) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, "consul:execute_release_tasks"
      end
    end
  end
end
