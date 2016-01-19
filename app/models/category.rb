class Category < ActiveRecord::Base
  has_many :subcategories
  serialize :name, JSON
  serialize :description, JSON

  validates :name, presence: true
end
