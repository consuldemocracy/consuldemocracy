
census_entities = []

CSV.foreach(Rails.root.join("config", "entidades_censo.csv"), headers: true, col_sep: "\;") do |row|
  census_entities.append({
    ine_code: row[0],
    nif: row[1],
    city_council: row[2],
    postal_code: row[3],
    entity: row[4],
    entity_code: row[5],
    city_council_name: row[6]
  })
end

CENSUS_ENTITIES = census_entities.freeze
postal_codes = CENSUS_ENTITIES.map { |entity| entity[:postal_code] }.uniq

census_dictionary = {}

postal_codes.each do |code|
  census_dictionary[code] = CENSUS_ENTITIES.select { |entity| entity[:postal_code] == code }
                                           .map { |e| e[:entity_code] }.uniq
end

CENSUS_DICTIONARY = census_dictionary.freeze

module Consul
  class Application < Rails::Application
    require Rails.root.join("lib/custom/census_api")
    require Rails.root.join("lib/custom/census_caller")

    config.i18n.default_locale = :es
    config.i18n.available_locales = [:es, :en]
  end
end
