if Rails.env.development?
  require "database_cleaner"
  DatabaseCleaner.clean_with :truncation
end

@logger = Logger.new(STDOUT)
@logger.formatter = proc do |_severity, _datetime, _progname, msg|
                      msg unless @avoid_log
                    end

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

def log(msg)
  @logger.info "#{msg}\n"
end

require_relative "djnd_seeds/settings"
require_relative "djnd_seeds/users"
require_relative "djnd_seeds/tags"
require_relative "djnd_seeds/budgets"
  
  log "All djnd seeds created successfuly 👍"
  