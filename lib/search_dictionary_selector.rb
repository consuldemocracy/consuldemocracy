module SearchDictionarySelector
  SQL_QUERY = "SELECT cfgname FROM pg_ts_config".freeze
  I18N_TO_DICTIONARY = {
    de: "german",
    dk: "danish",
    en: "english",
    es: "spanish",
    fi: "finnish",
    fr: "french",
    hu: "hungarian",
    it: "italian",
    nb: "norwegian",
    nl: "dutch",
    nn: "norwegian",
    pt: "portuguese",
    ro: "romanian",
    ru: "russian",
    sv: "swedish",
    tr: "turkish"
  }.freeze

  class << self
    def call
      find_from_i18n_default
    end

    private

      def find_from_i18n_default
        key_to_lookup = I18n.default_locale.to_s.split("-").first.to_sym

        dictionary = I18N_TO_DICTIONARY[key_to_lookup]
        dictionary ||= "simple"
        available_dictionaries.include?(dictionary) ? dictionary : available_dictionaries.first
      end

      def available_dictionaries
        result = ActiveRecord::Base.connection.execute(SQL_QUERY)
        result.to_a.map { |row| row["cfgname"] }
      end
  end
end
