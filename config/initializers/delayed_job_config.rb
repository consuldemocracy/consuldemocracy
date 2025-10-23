if Rails.env.test? || Rails.env.development?
  Delayed::Worker.delay_jobs = false
elsif Rails.application.secrets.delay_jobs.nil?
  Delayed::Worker.delay_jobs = true
else
  Delayed::Worker.delay_jobs = Rails.application.secrets.delay_jobs
end

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 2
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 1500.minutes
Delayed::Worker.read_ahead = 10
Delayed::Worker.default_queue_name = "default"
Delayed::Worker.raise_signal_exceptions = :term
Delayed::Worker.logger = Logger.new(File.join(Rails.root, "log", "delayed_job.log"))

if Delayed::Worker.delay_jobs
  Delayed::Worker.logger.warn "=== DELAYED JOB WORKER STARTING ==="
  Delayed::Worker.logger.warn "Current PATH: #{ENV['PATH']}"
  Delayed::Worker.logger.warn "Current working directory: #{Dir.pwd}"
  Delayed::Worker.logger.warn "Node location: #{`which node 2>/dev/null`.strip}"
  Delayed::Worker.logger.warn "NPX location: #{`which npx 2>/dev/null`.strip}"
  Delayed::Worker.logger.warn "====================================="
end

class ApartmentDelayedJobPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    lifecycle.before(:enqueue) { |job| job.tenant = Tenant.current_schema }

    lifecycle.around(:perform) do |worker, job, *args, &block|
      Tenant.switch(job.tenant) { block.call(worker, job, *args) }
    end
  end
end

Delayed::Worker.plugins << ApartmentDelayedJobPlugin
