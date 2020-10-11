class Budget
  class Ballot < ApplicationRecord
    belongs_to :user
    belongs_to :budget
    belongs_to :poll_ballot, class_name: "Poll::Ballot"

    has_many :lines, dependent: :destroy
    has_many :investments, through: :lines
    has_many :groups, -> { distinct }, through: :lines
    has_many :headings, -> { distinct }, through: :groups

    def add_investment(investment)
      lines.create(investment: investment).persisted?
    end

    def total_amount_spent
      investments.sum(:price).to_i
    end

    def has_lines_in_group?(group)
      groups.include?(group)
    end

    def wrong_budget?(heading)
      heading.budget_id != budget_id
    end

    def different_heading_assigned?(heading)
      other_heading_ids = heading.group.heading_ids - [heading.id]
      lines.where(heading_id: other_heading_ids).exists?
    end

    def valid_heading?(heading)
      !wrong_budget?(heading) && !different_heading_assigned?(heading)
    end

    def has_lines_with_no_heading?
      investments.no_heading.count > 0
    end

    def has_lines_with_heading?
      heading_id.present?
    end

    def has_lines_in_heading?(heading)
      investments.by_heading(heading.id).any?
    end

    def has_investment?(investment)
      investment_ids.include?(investment.id)
    end

    def heading_for_group(group)
      return nil unless has_lines_in_group?(group)

      investments.find_by(group: group).heading
    end

    def casted_offline?
      budget.poll&.voted_by?(user)
    end

    def voting_style
      @voting_style ||= voting_style_class.new(self)
    end
    delegate :amount_available, :amount_available_info, :amount_spent, :amount_spent_info, :amount_limit,
             :amount_limit_info, :change_vote_info, :enough_resources?, :formatted_amount_available,
             :formatted_amount_limit, :formatted_amount_spent, :not_enough_resources_error,
             :percentage_spent, :reason_for_not_being_ballotable, :voted_info,
             to: :voting_style

    private

      def voting_style_class
        "Budget::VotingStyles::#{budget.voting_style.camelize}".constantize
      end
  end
end
