require 'database_cleaner'
DatabaseCleaner.clean_with :truncation
@logger = Logger.new(STDOUT)
@logger.formatter = proc { |_severity, _datetime, _progname, msg| msg }

def section(section_title)
  @logger.info section_title
  yield
  log(' ✅')
end

def log(msg)
  @logger.info "#{msg}\n"
end

require_relative 'dev_seeds/settings'
require_relative 'dev_seeds/geozones'
require_relative 'dev_seeds/users'
require_relative 'dev_seeds/tags_categories'
require_relative 'dev_seeds/debates'
require_relative 'dev_seeds/proposals'
require_relative 'dev_seeds/budgets'
require_relative 'dev_seeds/spending_proposals'
require_relative 'dev_seeds/comments'
require_relative 'dev_seeds/votes'
require_relative 'dev_seeds/flags'
require_relative 'dev_seeds/hiddings'
require_relative 'dev_seeds/banners'
require_relative 'dev_seeds/polls'
require_relative 'dev_seeds/communities'
require_relative 'dev_seeds/legislation_processes'
require_relative 'dev_seeds/newsletters'
require_relative 'dev_seeds/notifications'
section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.reorder("RANDOM()").first.update(visible_to_valuators: true)
  end
end


log "All dev seeds created successfuly 👍"
