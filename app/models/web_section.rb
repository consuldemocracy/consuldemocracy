class WebSection < ActiveRecord::Base
  has_many :sections
  has_many :banners, through: :sections
end
