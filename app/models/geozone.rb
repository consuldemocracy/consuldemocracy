class Geozone < ApplicationRecord

  include Graphqlable

  has_many :proposals
  has_many :spending_proposals
  has_many :debates
  has_many :users
  validates :name, presence: true

  scope :public_for_api, -> { all }

  def self.names
    Geozone.pluck(:name)
  end

  def self.city
    where(name: "city").first
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end
