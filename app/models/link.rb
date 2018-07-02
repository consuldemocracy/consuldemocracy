class Link < ActiveRecord::Base
  belongs_to :linkable, polymorphic: true

  validates :label, presence: true
  validates :url, presence: true
  validates :linkable, presence: true 
end
