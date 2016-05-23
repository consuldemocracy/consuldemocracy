class Budget
  class Heading < ActiveRecord::Base
    belongs_to :budget
    belongs_to :geozone

    validates :budget_id, presence: true
    validates :name, presence: true
    validates :price, presence: true
  end
end
