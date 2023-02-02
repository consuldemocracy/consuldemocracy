class Admin::Stats::BudgetBallotingComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def vote_count
      budget.lines.count
    end

    def user_count
      budget.ballots.select { |ballot| ballot.lines.any? }.count
    end

    def vote_count_by_heading
      budget.lines.group(:heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort
    end

    def user_count_by_heading
      budget.headings.map do |heading|
        ballots = budget.ballots.joins(:lines).where(budget_ballot_lines: { heading_id: heading })

        [heading.name, ballots.select(:user_id).distinct.count]
      end.select { |_, count| count > 0 }.sort
    end
end
