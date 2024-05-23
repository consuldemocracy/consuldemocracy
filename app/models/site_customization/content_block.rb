class SiteCustomization::ContentBlock < ApplicationRecord
  VALID_BLOCKS = %w[top_links footer footer_legal subnavigation_left subnavigation_right].freeze

  validates :locale, presence: true, inclusion: { in: ->(*) { Setting.enabled_locales.map(&:to_s) }}
  validates :name, presence: true, uniqueness: { scope: :locale }, inclusion: { in: ->(*) { VALID_BLOCKS }}

  def self.block_for(name, locale = I18n.locale)
    find_by(name: name, locale: locale)&.body
  end
end
