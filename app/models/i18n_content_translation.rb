class I18nContentTranslation < ApplicationRecord
  def self.existing_locales
    self.select(:locale).distinct.map { |l| l.locale.to_sym }.to_a
  end
end
