begin
  set :init_config_files, %w[puma delayed_job]
  set :monit_config_files, %w[nginx postgres puma delayed_job]

  def upload_erb(from, to)
    if File.exist?(from)
      from_erb = StringIO.new(ERB.new(File.read(from)).result(binding))
      upload! from_erb, to
      info "copied: #{from} to: #{to}"
    else
      error "error #{from} not found"
    end
  end

  namespace :monit do
    desc "Install Monit"
    task :install do
      on roles(:all) do
        execute "sudo apt-get -y install monit"
      end
    end

    desc "Setup Monit"
    task :setup do
      on roles(:app) do
        fetch(:init_config_files).each do |file|
          execute "mkdir -p #{shared_path}/config/monit/init.d"
          upload_erb "lib/capistrano/monit/init.d/#{file}.erb", "#{shared_path}/config/monit/init.d/#{file}"
          execute "sudo cp #{shared_path}/config/monit/init.d/#{file} /etc/init.d/#{file}"
          execute "sudo chmod +x /etc/init.d/#{file}"
        end

        fetch(:monit_config_files).each do |file|
          execute "mkdir -p #{shared_path}/config/monit/conf.d"
          upload_erb "lib/capistrano/monit/conf.d/#{file}.erb", "#{shared_path}/config/monit/conf.d/#{file}"
          execute "sudo ln -nfs #{shared_path}/config/monit/conf.d/#{file} /etc/monit/conf.d/#{file}.conf"
        end
      end
    end

    %w[start stop restart].each do |command|
      desc "Run Monit #{command} script"
      task command do
        on roles(:all) do
          execute "sudo service monit #{command}"
        end
      end
    end

    desc "Reset Monit state to start monitoring again"
    task :reset do
      on roles(:all) do
        execute "sudo rm /var/lib/monit/state"
      end
    end

    desc "Clear Monit configuration"
    task :clear do
      on roles(:app) do
        execute "sudo rm -rf #{shared_path}/config/monit"

        fetch(:init_config_files).each do |file|
          execute "sudo rm /etc/init.d/#{file}"
        end

        fetch(:monit_config_files).each do |file|
          execute "sudo rm /etc/monit/conf.d/#{file}.conf"
        end
      end
    end

    after "monit:setup", "monit:restart"
    after "monit:reset", "monit:restart"
    after "monit:clear", "monit:restart"
  end
rescue NoMethodError
end
