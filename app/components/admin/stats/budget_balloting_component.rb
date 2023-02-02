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
      User.where.not(balloted_heading_id: nil).group(:balloted_heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort
    end
end
