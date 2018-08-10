class Budget
  class Group < ActiveRecord::Base
    include Sluggable

    belongs_to :budget

    has_many :headings, dependent: :destroy

    validates :budget_id, presence: true
    validates :name, presence: true, uniqueness: { scope: :budget }
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :voting_style, inclusion: { in: Vote::KINDS }
    validates :number_votes_per_heading, :numericality => { greater_than_or_equal_to: 1 }

    def single_heading_group?
      headings.count == 1
    end

    def approval_voting?
      voting_style == "approval"
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
