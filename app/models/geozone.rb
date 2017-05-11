class Geozone < ActiveRecord::Base
  has_many :proposals
  has_many :spending_proposals
  has_many :debates
  has_many :users
  has_and_belongs_to_many :problems
  validates :name, presence: true

  def self.names
    Geozone.pluck(:name)
  end

  def self.city
    where(name: 'city').first
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end
