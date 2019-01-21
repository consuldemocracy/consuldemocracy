class SubArea < ActiveRecord::Base
  validates :name, presence: true

  translates :name, touch: true
  include Globalizable

  belongs_to :area
  has_many :investments, class_name: "Budget::Investment"
end
