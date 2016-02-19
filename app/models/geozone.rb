class Geozone < ActiveRecord::Base
  validates :name, presence: true

  def self.names
    Geozone.all.map(&:name)
  end
end
