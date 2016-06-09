class Budget
  class Heading < ActiveRecord::Base
    belongs_to :group
    belongs_to :geozone

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true
    validates :price, presence: true
  end
end
