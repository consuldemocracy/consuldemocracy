class Area < ActiveRecord::Base
  include Imageable

  validates :name, presence: true

  translates :name, touch: true
  include Globalizable

  has_many :sub_areas
end
