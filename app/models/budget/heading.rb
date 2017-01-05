class Budget
  class Heading < ActiveRecord::Base
    belongs_to :group

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true
    validates :price, presence: true

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> { includes(:group).order('budget_groups.name', 'budget_headings.name') }

    def name_scoped_by_group
      "#{group.name}: #{name}"
    end

  end
end
