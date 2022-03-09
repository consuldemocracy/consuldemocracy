class SDG::Relation < ApplicationRecord
  validates :related_sdg_id, uniqueness: { scope: [:related_sdg_type, :relatable_id, :relatable_type] }

  belongs_to :relatable, polymorphic: true, optional: false, touch: true
  belongs_to :related_sdg, polymorphic: true, optional: false
end
