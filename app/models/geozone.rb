class Geozone < ActiveRecord::Base
  has_many :spending_proposals
  validates :name, presence: true

  def self.names
    Geozone.pluck(:name)
  end

  def self.city
    where(name: 'city').first
  end

end
