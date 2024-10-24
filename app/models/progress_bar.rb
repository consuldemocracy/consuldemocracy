class ProgressBar < ApplicationRecord
  self.inheritance_column = nil
  RANGE = (0..100)

  enum :kind, { primary: 0, secondary: 1 }

  belongs_to :progressable, polymorphic: true

  translates :title, touch: true
  include Globalizable
  translation_class_delegate :primary?

  validates :progressable, presence: true
  validates :kind, presence: true,
                   uniqueness: {
                     scope: [:progressable_type, :progressable_id],
                     conditions: -> { primary }
                   }
  validates :percentage,
            presence: true,
            inclusion: { in: ->(*) { RANGE }},
            numericality: { only_integer: true }

  validates_translation :title, presence: true, unless: :primary?
end
