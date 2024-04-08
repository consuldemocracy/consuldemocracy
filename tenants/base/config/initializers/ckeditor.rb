Ckeditor.setup do |config|
  # ==> ORM configuration
  # Load and configure the ORM. Supports :active_record (default), :mongo_mapper and
  # :mongoid (bson_ext recommended) by default. Other ORMs may be
  # available as additional gems.
  require "ckeditor/orm/active_record"

  config.authorize_with :cancan

  config.assets_languages = Rails.application.config.i18n.available_locales.map { |l| l.to_s.downcase }
  config.assets_plugins = %w[image link magicline pastefromword table tableselection
                             tabletools mediaembed iframe]
  config.assets.reject! { |asset| asset.starts_with?("ckeditor/samples/") }

  #handle custom plugins
  assets_root = Rails.root.join("app", "assets", "javascripts")
  ckeditor_plugins_root = assets_root.join("ckeditor", "plugins")
  %w[mediaembed].each do |ckeditor_plugin|
    Ckeditor.assets += Dir[ckeditor_plugins_root.join(ckeditor_plugin, "**", "*")].map do |x|
      x.sub(assets_root.to_path, "").sub(/^\/+/, "")
    end
  end
end
