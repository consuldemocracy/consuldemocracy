class Category < ActiveRecord::Base
  default_scope { order(position: :asc) }

  has_many :subcategories, -> { order(position: :asc) }

  serialize :name, JSON
  serialize :description, JSON

  validates :name, presence: true
end
