#!/usr/bin/env puma

rails_root = File.expand_path("../../..", __FILE__)

directory rails_root
rackup "#{rails_root}/config.ru"

tag ""

pidfile "#{rails_root}/tmp/pids/puma.pid"
state_path "#{rails_root}/tmp/pids/puma.state"
stdout_redirect "#{rails_root}/log/puma_access.log", "#{rails_root}/log/puma_error.log", true

bind "unix://#{rails_root}/tmp/sockets/puma.sock"

threads 0, 16
workers 2
preload_app!

plugin :tmp_restart

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = ""
end
