class I18nContentTranslation < ApplicationRecord
  def self.existing_locales
    distinct.pluck(:locale).map(&:to_sym)
  end
end
