namespace :locales do
  desc 'Migrate all localization files to new structure for a given locale name as argument'
  task :migrate_structure, [:locale] => [:environment] do |_t, args|
    locale = args[:locale]
    puts "Moving files for locale: #{locale}"

    # This creates ./config/locales/en/ directory
    system "mkdir ./config/locales/#{locale}"

    # This moves from ./config/locales/en.yml to ./config/locales/en/general.yml
    system "mv ./config/locales/#{locale}.yml ./config/locales/#{locale}/general.yml"

    # This moves from ./config/locales/admin.en.yml to ./config/locales/en/admin.en.yml
    system "mv ./config/locales/*.#{locale}.yml ./config/locales/#{locale}/"

    # This moves from ./config/locales/en/admin.en.yml to ./config/locales/en/admin.yml
    system "find ./config/locales/ -name \"*.#{locale}.yml\" -exec sh -c 'mv \"$1\" \"${1%.#{locale}.yml}.yml\"' _ {} \\;"

    puts "Moved!"
  end
end

