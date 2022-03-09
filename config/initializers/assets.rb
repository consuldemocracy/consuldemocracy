# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w[ckeditor/config.js]
Rails.application.config.assets.precompile += %w[stat_graphs.js]
Rails.application.config.assets.precompile += %w[dashboard_graphs.js]
Rails.application.config.assets.precompile += %w[print.css]
Rails.application.config.assets.precompile += %w[pdf_fonts.css]
Rails.application.config.assets.precompile += %w[sdg/*.png]
Rails.application.config.assets.precompile += %w[sdg/**/*.png]

# Loads custom images and custom fonts before app/assets/images and app/assets/fonts
