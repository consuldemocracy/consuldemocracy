class Geozone < ActiveRecord::Base
  has_many :proposals
  has_many :spending_proposals
  has_many :debates
  has_many :users
  validates :name, presence: true

  def self.names
    Geozone.pluck(:name)
  end

end
