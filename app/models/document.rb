class Document < ActiveRecord::Base
  belongs_to :user
  belongs_to :documentable, polymorphic: true

  validates :user_id, presence: true
  validates :documentable_id, presence: true
  validates :documentable_type, presence: true

end
