class Category < ActiveRecord::Base
  has_many :subcategories
  serialize :name, JSON

  validates :name, presence: true
end
