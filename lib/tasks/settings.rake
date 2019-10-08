namespace :settings do
  desc "Add new settings"
  task add_new_settings: :environment do
    ApplicationLogger.new.info "Adding new settings"
    Setting.add_new_settings
  end
end
