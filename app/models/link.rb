class Link < ApplicationRecord
  belongs_to :linkable, polymorphic: true

  validates :label, presence: true
  validates :url, presence: true
end
