# Puma can serve each request in a thread from an internal thread pool.
# Default is set to 5 threads for minimum and maximum, matching the
# default thread size of Active Record.
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }.to_i
threads threads_count, threads_count

port        ENV.fetch("PORT") { 3000 }
environment "development"

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
