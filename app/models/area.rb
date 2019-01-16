class Area < ActiveRecord::Base
  validates :name, presence: true

  translates :name, touch: true
  include Globalizable

  has_many :sub_areas
end
