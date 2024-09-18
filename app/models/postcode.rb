class Postcode < ApplicationRecord
  include Graphqlable

  belongs_to :geozone
  validates :postcode, presence: true
  scope :public_for_api, -> { all }

  def self.names
    Postcode.pluck(:postcode)
  end

  def self.find_by_normalized_postcode(postcode)
    normalized_postcode = postcode.gsub(/\s+/, '').downcase
    where("REPLACE(LOWER(postcode), ' ', '') = ?", normalized_postcode).first
  end


  def safe_to_destroy?
    Postcode.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(name: self).empty?
    end
  end

  def human_name
  end
end
