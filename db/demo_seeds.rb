Tenant.destroy_all if Tenant.default?
internal_tables = [
  ActiveRecord::Base.internal_metadata_table_name,
  ActiveRecord::Base.schema_migrations_table_name
]
tables = ActiveRecord::Base.connection.tables - internal_tables

ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{tables.join(", ")} RESTART IDENTITY")

@logger = Logger.new(STDOUT)
@logger.formatter = proc { |_severity, _datetime, _progname, msg| msg }

def load_demo_seeds(demo_seeds_file)
  load Rails.root.join("db", "demo_seeds", "#{demo_seeds_file}.rb")
end

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

log "Creating demo seeds for tenant #{Tenant.current_schema}" unless Tenant.default?
load Rails.root.join("db", "seeds.rb")

load_demo_seeds "settings"
load_demo_seeds "geozones"
load_demo_seeds "users"
load_demo_seeds "tags_categories"
load_demo_seeds "debates"
load_demo_seeds "proposals"
load_demo_seeds "polls"
load_demo_seeds "legislation_processes"
load_demo_seeds "budgets"
load_demo_seeds "widgets"
load_demo_seeds "sdg"
load_demo_seeds "tenants" if Tenant.default?

log "DEMO seeds created successfuly 👍"
