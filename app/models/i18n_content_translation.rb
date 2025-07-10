class I18nContentTranslation < ApplicationRecord
  def self.existing_languages
    self.select(:locale).distinct.map { |l| l.locale.to_sym }.to_a
  end
end
