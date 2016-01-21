class Subcategory < ActiveRecord::Base
  belongs_to :category
  serialize :name, JSON
  serialize :description, JSON

  validates :name, :category, presence: true
end
