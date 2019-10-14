class Commission < ActiveRecord::Base
  belongs_to :geozone
  has_many :users

  validates :name, presence: true, uniqueness: true
  validates :place, presence: true
  validates :geozone_id, presence: true
end
