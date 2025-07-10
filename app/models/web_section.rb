class WebSection < ApplicationRecord
  has_many :sections
  has_many :banners, through: :sections
end
