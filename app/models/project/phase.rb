class Project
  class Phase < ApplicationRecord

    TITLE_SHORT_MAX_LENGTH = 80
    SUBTITLE_MAX_LENGTH = 80

    translates :title, touch: true
    translates :title_short, touch: true
    translates :content, touch: true
    translates :subtitle, touch: true
    include Globalizable
    include Sanitizable
    include Imageable
    include Cardable

    belongs_to :project, touch: true

    validates_translation :title, presence: true
    validates_translation :content, presence: true
    validates_translation :title_short, presence: true, length: { maximum: ->(*) { TITLE_SHORT_MAX_LENGTH }}
    validates_translation :subtitle, length: { maximum: ->(*) { SUBTITLE_MAX_LENGTH }}
    validates :project, presence: true
    validate :invalid_dates_range?

    scope :enabled,           -> { where(enabled: true) }
    scope :sort_by_order, -> { order(:order, :created_at) }

    def invalid_dates_range?
      if starts_at.present? && ends_at.present? && starts_at >= ends_at
        errors.add(:starts_at, I18n.t("admin.projects.phases.errors.dates_range_invalid"))
      end
    end

  	def name
  		title
  	end

  end
end
