class Budget
  class Heading < ActiveRecord::Base
    belongs_to :group
    belongs_to :geozone

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true
    validates :price, presence: true

    scope :order_by_group_name, -> { includes(:group).order('budget_groups.name', 'budget_headings.name') }

    def budget
      group.budget
    end

    def budget=(resource)
      group.budget = resource
    end

    def name_scoped_by_group
      "#{group.name}: #{name}"
    end

  end
end
