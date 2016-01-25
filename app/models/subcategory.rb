class Subcategory < ActiveRecord::Base
  default_scope { order(position: :asc) }

  belongs_to :category
  serialize :name, JSON
  serialize :description, JSON

  validates :name, :category, presence: true
end
