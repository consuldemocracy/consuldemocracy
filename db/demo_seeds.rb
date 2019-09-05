@logger = Logger.new(STDOUT)
@logger.formatter = proc { |_severity, _datetime, _progname, msg| msg }

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

def log(msg)
  @logger.info "#{msg}\n"
end

def users
  User.last(10)
end

def add_image(image, imageable)
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: image,
    user: imageable.author
  })
  imageable.save
end

load Rails.root.join("db", "seeds.rb")

require_relative "demo_seeds/settings"
require_relative "demo_seeds/geozones"
require_relative "demo_seeds/users"
require_relative "demo_seeds/tags_categories"
require_relative "demo_seeds/debates"
require_relative "demo_seeds/proposals"
require_relative "demo_seeds/polls"
require_relative "demo_seeds/legislation_processes"
require_relative "demo_seeds/budgets"
require_relative "demo_seeds/widgets"
require_relative "demo_seeds/sdg"

log "DEMO seeds created successfuly 👍"
