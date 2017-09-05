class Follow < ActiveRecord::Base
  belongs_to :user
  belongs_to :followable, polymorphic: true

  validates :user_id, presence: true
  validates :followable_id, presence: true
  validates :followable_type, presence: true
end
