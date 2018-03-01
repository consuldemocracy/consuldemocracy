class Budget
  class Heading < ActiveRecord::Base
    include Sluggable

    belongs_to :group

    has_many :investments
    has_many :budget_heading_voters, class_name: "Budget::Heading::Voter", foreign_key: :budget_heading_id
    has_many :voters, through: :budget_heading_voters, source: :user

    validates :group_id, presence: true
    validates :name, presence: true, uniqueness: { if: :name_exists_in_budget_headings }
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> { includes(:group).order('budget_groups.name', 'budget_headings.name') }

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def name_exists_in_budget_headings
      group.budget.headings.where(name: name).where.not(id: id).any?
    end

    def can_be_deleted?
      investments.empty?
    end

    def already_voted_in_by_user?(user)
      voters.include?(user)
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
