@logger = Logger.new(STDOUT)
@logger.formatter = proc { |_severity, _datetime, _progname, msg| msg }

def section(section_title)
  @logger.info section_title
  yield
  log(' ✅')
end

def log(msg)
  @logger.info "#{msg}\n" unless Rails.env.test?
end

require_relative 'custom_seeds/settings'
require_relative 'custom_seeds/geozones'
#require_relative 'custom_seeds/users'
#require_relative 'custom_seeds/tags_categories'
#require_relative 'custom_seeds/debates'
#require_relative 'custom_seeds/proposals'
#require_relative 'custom_seeds/budgets'
#require_relative 'custom_seeds/spending_proposals'
#require_relative 'custom_seeds/comments'
#require_relative 'custom_seeds/votes'
#require_relative 'custom_seeds/flags'
#require_relative 'custom_seeds/hiddings'
#require_relative 'custom_seeds/banners'
#require_relative 'custom_seeds/polls'
#require_relative 'custom_seeds/communities'
#require_relative 'custom_seeds/legislation_processes'
#require_relative 'custom_seeds/newsletters'

log "All custom seeds created successfuly ✅"
