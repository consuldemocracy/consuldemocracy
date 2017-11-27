class RelatedContent < ActiveRecord::Base
  belongs_to :parent_relationable, polymorphic: true
  belongs_to :child_relationable, polymorphic: true

  validates :parent_relationable_id, presence: true
  validates :parent_relationable_type, presence: true
  validates :child_relationable_id, presence: true
  validates :child_relationable_type, presence: true
  validates :parent_relationable_id, uniqueness: { scope: [:parent_relationable_type, :child_relationable_id, :child_relationable_type] }

end
