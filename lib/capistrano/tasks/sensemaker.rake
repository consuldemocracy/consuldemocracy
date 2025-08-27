namespace :sensemaker do
  desc "Setup Sensemaking Tools on the remote server"
  task :setup do
    on roles(:app) do
      within current_path do
        execute :rake, "sensemaker:setup"
      end
    end
  end

  desc "Check Sensemaking Tools dependencies on the remote server"
  task :check_dependencies do
    on roles(:app) do
      within current_path do
        execute :rake, "sensemaker:check_dependencies"
      end
    end
  end
end
