module SearchDictionarySelector
  SQL_QUERY = "SELECT cfgname FROM pg_ts_config".freeze
  I18N_TO_DICTIONARY = {
    en: "english",
    de: "german",
    fi: "finnish",
    fr: "french",
    dk: "danish",
    nl: "dutch",
    hu: "hungarian",
    it: "italian",
    nn: "norwegian",
    nb: "norwegian",
    pt: "portuguese",
    ro: "romanian",
    ru: "russian",
    es: "spanish",
    sv: "swedish",
    tr: "turkish"
  }.freeze

  class << self
    def call
      find_from_i18n_default
    end

    private

    def find_from_i18n_default
      # some locales have more complex keys, such as fr-CA
      key_to_lookup = I18n.default_locale.to_s[0..1].to_sym

      dictionary = I18N_TO_DICTIONARY[key_to_lookup]
      dictionary ||= "simple"
      available_dictionaries.include?(dictionary) ? dictionary : available_dictionaries.first
    end

    def available_dictionaries
      @available_dictionaries ||= begin
        result = ActiveRecord::Base.connection.execute(SQL_QUERY)
        result.to_a.map { |r| r["cfgname"] }
      end
    end
  end
end