class ProgressBar < ActiveRecord::Base
  self.inheritance_column = nil
  RANGE = 0..100

  enum kind: %i[primary secondary]

  belongs_to :progressable, polymorphic: true

  translates :title, touch: true
  include Globalizable

  validates :progressable, presence: true
  validates :kind, presence: true,
            uniqueness: {
              scope: [:progressable_type, :progressable_id],
              conditions: -> { primary }
            }
  validates :percentage, presence: true, inclusion: RANGE, numericality: { only_integer: true }

  before_validation :assign_progress_bar_to_translations
  validates_translation :title, presence: true, unless: :primary?

  private

    def assign_progress_bar_to_translations
      translations.each { |translation| translation.globalized_model = self }
    end
end
