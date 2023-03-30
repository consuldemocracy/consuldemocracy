class Postcode < ApplicationRecord
  include Graphqlable

  has_many :geozones
  validates :postcode, presence: true
  scope :public_for_api, -> { all }

  def self.names
    Postcode.pluck(:postcode)
  end

  def safe_to_destroy?
    Postcode.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end
