class Geozone < ApplicationRecord
  has_many :spending_proposals
  validates :name, presence: true

  def self.names
    Geozone.pluck(:name)
  end

end
