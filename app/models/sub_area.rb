class SubArea < ActiveRecord::Base
  belongs_to :area
  has_many :investments, class_name: "Budget::Investment"
end
