class Budget
  class Heading < ActiveRecord::Base
    include Sluggable

    belongs_to :group

    has_many :investments

    validates :group_id, presence: true
    validates :name, presence: true, uniqueness: { if: :name_exists_in_budget_headings }
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> do
      includes(:group).order('budget_groups.name DESC', 'budget_headings.name')
    end

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def to_param
      name.parameterize
    end

    def name_exists_in_budget_headings
      group.budget.headings.where(name: name).where.not(id: id).any?
    end

    def can_be_deleted?
      investments.empty?
    end

    def city_heading?
      name == "Toda la ciudad"
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
