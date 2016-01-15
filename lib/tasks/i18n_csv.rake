namespace :i18n_csv do
  desc "Updates all debates by recalculating their hot_score"
  task generate: :environment do
    filenames = Dir.glob(Rails.root.join('config', 'locales', '*.yml')).map do |filename|
      matchdata = /.*\/(.+)\..+\.yml$/.match(filename)
      matchdata[1] if matchdata
    end

    filenames.compact.uniq.each do |name| 
      output_file = Rails.root.join("config", "locales", "#{name}.csv")
      puts "Exporting #{output_file}"

      translations = I18n.available_locales.inject({}) do |result, locale|
        data = YAML.load_file(Rails.root.join('config', 'locales', "#{name}.#{locale}.yml"))
        result.merge(data)
      end

      File.write(output_file, I18nYamlCsv.generate_csv(translations))
    end
  end
end
