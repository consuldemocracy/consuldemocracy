unless Rails.env.test?
  Tenant.destroy_all if Tenant.default?
  ActiveRecord::Tasks::DatabaseTasks.truncate_all
end

@logger = Logger.new(STDOUT)
@logger.formatter = proc do |_severity, _datetime, _progname, msg|
  msg unless Rails.env.test?
end

def load_dev_seeds(dev_seeds_file)
  load Rails.root.join("db", "dev_seeds", "#{dev_seeds_file}.rb")
end

def section(section_title)
  @logger.info section_title
  yield
  log(" ✅")
end

def log(msg)
  @logger.info "#{msg}\n"
end

def random_locales
  [I18n.default_locale, *(I18n.available_locales & %i[en es]), *I18n.available_locales.sample(4)].uniq.take(5)
end

def random_locales_attributes(**attribute_names_with_values)
  random_locales.each_with_object({}) do |locale, attributes|
    I18n.with_locale(locale) do
      attribute_names_with_values.each do |attribute_name, value_proc|
        attributes["#{attribute_name}_#{locale.to_s.underscore}"] = value_proc.call
      end
    end
  end
end

def add_image_to(imageable, sample_image_files)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: Rack::Test::UploadedFile.new(sample_image_files.sample),
    user: imageable.author
  })
  imageable.save!
end

log "Creating dev seeds for tenant #{Tenant.current_schema}" unless Tenant.default?

load_dev_seeds "settings"
load_dev_seeds "geozones"
load_dev_seeds "users"
load_dev_seeds "tags_categories"
load_dev_seeds "debates"
load_dev_seeds "proposals"
load_dev_seeds "budgets"
load_dev_seeds "comments"
load_dev_seeds "votes"
load_dev_seeds "flags"
load_dev_seeds "hiddings"
load_dev_seeds "banners"
load_dev_seeds "polls"
load_dev_seeds "communities"
load_dev_seeds "legislation_processes"
load_dev_seeds "newsletters"
load_dev_seeds "notifications"
load_dev_seeds "widgets"
load_dev_seeds "admin_notifications"
load_dev_seeds "legislation_proposals"
load_dev_seeds "milestones"
load_dev_seeds "pages"
load_dev_seeds "sdg"

log "All dev seeds created successfuly 👍"
