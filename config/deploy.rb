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
set :deploy_to, deploysecret(:deploy_to)
set :server_name, deploysecret(:server_name)
set :db_server, deploysecret(:db_server)
set :ssh_options, port: deploysecret(:ssh_port)

set :repo_url, "https://github.com/consuldev/consul.git"

set :revision, `git rev-parse --short #{fetch(:branch)}`.strip

set :log_level, :info
set :pty, true
set :use_sudo, false

set :linked_files, %w[config/database.yml config/secrets.yml]
set :linked_dirs, %w[log tmp public/system public/assets public/ckeditor_assets]

set :keep_releases, 5

set :local_user, ENV["USER"]

set :puma_conf, "#{release_path}/config/puma/#{fetch(:rails_env)}.rb"

set :delayed_job_workers, 2
set :delayed_job_roles, :background

set(:config_files, %w[
  log_rotation
  database.yml
  secrets.yml
])

set :whenever_roles, -> { :app }

namespace :deploy do
  after :updating, "rvm1:install:rvm"
  after :updating, "rvm1:install:ruby"
  after :updating, "install_bundler_gem"
  before "deploy:migrate", "remove_local_census_records_duplicates"

  after "deploy:migrate", "add_new_settings"

  before :publishing, "smtp_ssl_and_delay_jobs_secrets"
  after  :publishing, "setup_puma"

  after :published, "deploy:restart"
  before "deploy:restart", "puma:smart_restart"
  before "deploy:restart", "delayed_job:restart"

  after :finished, "refresh_sitemap"

  desc "Deploys and runs the tasks needed to upgrade to a new release"
  task :upgrade do
    after "add_new_settings", "execute_release_tasks"
    invoke "deploy"
  end
end

task :install_bundler_gem do
  on roles(:app) do
    within release_path do
      execute :rvm, fetch(:rvm1_ruby_version), "do", "gem install bundler --version 1.17.1"
    end
  end
end

task :remove_local_census_records_duplicates do
  on roles(:db) do
    within release_path do
      with rails_env: fetch(:rails_env) do
        execute :rake, "local_census_records:remove_duplicates"
      end
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

task :smtp_ssl_and_delay_jobs_secrets do
  on roles(:app) do
    if test("[ -d #{current_path} ]")
      within current_path do
        with rails_env: fetch(:rails_env) do
          tasks_file_path = "lib/tasks/secrets.rake"
          shared_secrets_path = "#{shared_path}/config/secrets.yml"

          unless test("[ -e #{current_path}/#{tasks_file_path} ]")
            begin
              unless test("[ -w #{shared_secrets_path} ]")
                execute "sudo chown `whoami` #{shared_secrets_path}"
                execute "chmod u+w #{shared_secrets_path}"
              end

              execute "cp #{release_path}/#{tasks_file_path} #{current_path}/#{tasks_file_path}"

              execute :rake, "secrets:smtp_ssl_and_delay_jobs"
            ensure
              execute "rm #{current_path}/#{tasks_file_path}"
            end
          end
        end
      end
    end
  end
end
