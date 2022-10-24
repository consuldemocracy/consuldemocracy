class Geozone < ApplicationRecord
  include Graphqlable

  has_many :proposals
  has_many :debates
  has_many :users
  has_many :budget_investments
  validates :name, presence: true

  scope :public_for_api, -> { all }

  def self.names
    Geozone.pluck(:name)
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end
end

# == Schema Information
#
# Table name: geozones
#
#  id                   :integer          not null, primary key
#  name                 :string
#  html_map_coordinates :string
#  external_code        :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  census_code          :string
#
