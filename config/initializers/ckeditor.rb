Ckeditor.setup do |config|
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default), :mongo_mapper and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require 'ckeditor/orm/active_record'

  config.authorize_with :cancan

  config.assets_languages = Rails.application.config.i18n.available_locales.map{|l| l.to_s.downcase}
  config.assets_plugins = %w[copyformatting tableselection scayt wsc]
end
