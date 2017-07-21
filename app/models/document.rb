class Document < ActiveRecord::Base
  has_attached_file :attachment

  belongs_to :user
  belongs_to :documentable, polymorphic: true

  validates_attachment :attachment, presence: true,
    content_type: { content_type: "application/pdf" },
    size: { in: 0..3.megabytes }
  validates :title, presence: true
  validates :user, presence: true
  validates :documentable_id, presence: true
  validates :documentable_type, presence: true

end
