class WebSection < ApplicationRecord
  has_many :sections
  has_many :banners, through: :sections
  has_one :header, class_name: "Widget::Card", as: :cardable, dependent: :destroy
end
