class Geozone < ActiveRecord::Base
  validates :name, presence: true
end
