namespace :i18n_csv do
  desc "Generates a CSV file for every translation"
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

  desc "Imports translations from CSVs with the same name"
  task import: :environment do
    Dir.glob(Rails.root.join('config', 'locales', '*.csv')).each do |filename|
      puts "Importing #{filename}"

      matchdata = /.*\/(.+)\.csv$/.match(filename)
      next unless matchdata
      name = matchdata[1]

      data = I18nYamlCsv.from_csv(File.read(filename)).deep_stringify_keys

      locales = data.keys

      locales.each do |locale| 
        yaml = YAML.dump({locale => data[locale]})
        File.write(Rails.root.join('config', 'locales', "#{name}.#{locale}.yml"), yaml)
      end
    end
  end
end
