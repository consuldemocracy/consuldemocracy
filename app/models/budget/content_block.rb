class Budget
  class ContentBlock < ActiveRecord::Base
    validates :locale, presence: true, inclusion: { in: I18n.available_locales.map(&:to_s) }
    validates :heading, presence: true
    validates_uniqueness_of :heading, scope: :locale

    belongs_to :heading
  end
end
