class Category < ActiveRecord::Base
  has_many :subcategories, -> { order(position: :asc) }
  serialize :name, JSON
  serialize :description, JSON

  validates :name, presence: true
end
