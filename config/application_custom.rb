
census_entities = []
census_geozones = []

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

census_geozones = CSV.open(Rails.root.join("config", "census_geozones.csv"), headers: true).map(&:to_h)

CENSUS_ENTITIES = census_entities.freeze
CENSUS_GEOZONES = census_geozones.freeze

postal_codes = CENSUS_ENTITIES.map { |entity| entity[:postal_code] }.uniq

census_dictionary = {}

postal_codes.each do |code|
  census_dictionary[code] = CENSUS_ENTITIES.select { |entity| entity[:postal_code] == code }
                                           .map { |e| e[:entity_code] }.uniq
end

geozones_dictionary = CENSUS_GEOZONES.map { |e| [e["entity_code"], e["geozone_external_code"]] }.to_h.except(nil)

CENSUS_DICTIONARY = census_dictionary.freeze
GEOZONES_DICTIONARY= geozones_dictionary.freeze

# puts JSON.pretty_generate(CENSUS_DICTIONARY) if Rails.env.development?

I18n.enforce_available_locales = false

module Consul
  class Application < Rails::Application
    require Rails.root.join("lib/custom/custom_census_api")
    require Rails.root.join("lib/custom/census_caller")

    config.i18n.default_locale = :es

    if Rails.env.development?
      config.i18n.available_locales = [:es, :en] # Otherwise db:dev_seed breaks
    else
      config.i18n.available_locales = [:es]
    end
  end
end
