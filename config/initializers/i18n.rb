I18n.available_locales = [:en, :es]

I18n.default_locale = :es

# Add the new directories to the locales load path
I18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
