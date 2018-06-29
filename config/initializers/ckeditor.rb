Ckeditor.setup do |config|
  config.assets_languages = Rails.application.config.i18n.available_locales.map{|l| l.to_s.downcase}
  config.assets_plugins = %w[copyformatting tableselection scayt wsc]
end
