class Budget
  class Heading < ActiveRecord::Base
    belongs_to :budget
    belongs_to :geozone

    has_many :investments

    validates :budget_id, presence: true
    validates :name, presence: true
    validates :price, presence: true
  end
end
