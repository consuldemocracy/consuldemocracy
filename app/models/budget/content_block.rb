class Budget
  class ContentBlock < ApplicationRecord
    validates :locale, presence: true, inclusion: { in: ->(*) { Setting.enabled_locales.map(&:to_s) }}
    validates :heading, presence: true, uniqueness: { scope: :locale }

    belongs_to :heading
    delegate :name, to: :heading, allow_nil: true
  end
end
