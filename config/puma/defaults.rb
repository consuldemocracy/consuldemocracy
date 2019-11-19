#!/usr/bin/env puma

rails_root = File.expand_path("../../..", __FILE__)

directory rails_root
rackup "#{rails_root}/config.ru"

tag ""

pidfile "#{rails_root}/tmp/pids/puma.pid"
state_path "#{rails_root}/tmp/pids/puma.state"
stdout_redirect "#{rails_root}/log/puma_access.log", "#{rails_root}/log/puma_error.log", true

bind "unix://#{rails_root}/tmp/sockets/puma.sock"
daemonize

threads 0, 16
workers 2
preload_app!

restart_command "bundle exec --keep-file-descriptors puma"
plugin :tmp_restart

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end

before_fork do
  ActiveRecord::Base.connection_pool.disconnect!
end

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
