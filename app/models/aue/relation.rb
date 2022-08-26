class AUE::Relation < ApplicationRecord
  validates :related_aue_id, uniqueness: { scope: [:related_aue_type, :relatable_id, :relatable_type] }

  belongs_to :relatable, polymorphic: true, optional: false, touch: true
  belongs_to :related_aue, polymorphic: true, optional: false
end
