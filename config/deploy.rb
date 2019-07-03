# config valid only for current version of Capistrano
lock "~> 3.10.1"

def deploysecret(key)
  @deploy_secrets_yml ||= YAML.load_file("config/deploy-secrets.yml")[fetch(:stage).to_s]
  @deploy_secrets_yml.fetch(key.to_s, "undefined")
end

set :rails_env, fetch(:stage)
set :rvm1_map_bins, -> { fetch(:rvm_map_bins).to_a.concat(%w[rake gem bundle ruby]).uniq }

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
  before :starting, "rvm1:install:rvm"
  before :starting, "rvm1:install:ruby"
  before :starting, "install_bundler_gem"

  after "deploy:migrate", "add_new_settings"
  after :publishing, "deploy:restart"
  after :published, "delayed_job:restart"
  after :published, "refresh_sitemap"

  before "deploy:restart", "setup_puma"

  after :finishing, "deploy:cleanup"

  desc "Deploys and runs the tasks needed to upgrade to a new release"
  task :upgrade do
    after "add_new_settings", "execute_release_tasks"
    invoke "deploy"
  end
end

task :install_bundler_gem do
  on roles(:app) do
    within release_path do
      execute :rvm, fetch(:rvm1_ruby_version), "do", "gem install bundler"
    end
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

desc "Create pid and socket folders needed by puma and convert unicorn sockets into symbolic links \
      to the puma socket, so legacy nginx configurations pointing to the unicorn socket keep working"
task :setup_puma do
  on roles(:app) do
    with rails_env: fetch(:rails_env) do
      execute "mkdir -p #{shared_path}/tmp/sockets; true"
      execute "mkdir -p #{shared_path}/tmp/pids; true"

      if test("[ -e #{shared_path}/tmp/sockets/unicorn.sock ]")
        execute "ln -sf #{shared_path}/tmp/sockets/puma.sock #{shared_path}/tmp/sockets/unicorn.sock; true"
      end

      if test("[ -e #{shared_path}/sockets/unicorn.sock ]")
        execute "ln -sf #{shared_path}/tmp/sockets/puma.sock #{shared_path}/sockets/unicorn.sock; true"
      end
    end
  end
end
