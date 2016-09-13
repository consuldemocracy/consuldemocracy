class Budget
  class Heading < ActiveRecord::Base
    belongs_to :group
    belongs_to :geozone

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true
    validates :price, presence: true

    def budget
      group.budget
    end

    def budget=(resource)
      group.budget = resource
    end

  end
end
