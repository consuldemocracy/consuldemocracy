class Geozone < ActiveRecord::Base
  validates :name, presence: true

  def self.names
    Geozone.pluck(:name)
  end
end
