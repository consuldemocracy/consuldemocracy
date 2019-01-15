class Area < ActiveRecord::Base
  validates :name, presence: true

  translates :name, touch: true
  include Globalizable
end
