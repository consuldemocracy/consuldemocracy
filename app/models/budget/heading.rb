class Budget
  class Heading < ActiveRecord::Base
    include Sluggable

    belongs_to :group

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true, uniqueness: { if: :name_exists_in_budget_headings }
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> { includes(:group).order('budget_groups.name', 'budget_headings.name') }

    def name_scoped_by_group
      "#{group.name}: #{name}"
    end

    def name_exists_in_budget_headings
      group.budget.headings.where(name: name).any?
    end

  end
end
