class Admin::Stats::BudgetBallotingComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def stats
      @stats ||= Budget::Stats.new(budget)
    end

    def headings_stats
      @headings_stats ||= stats.headings
    end

    def vote_count
      stats.total_votes
    end

    def user_count
      stats.total_participants_vote_phase
    end

    def vote_count_by_heading
      budget.lines.group(:heading_id).count.map { |k, v| [Budget::Heading.find(k).name, v] }.sort
    end

    def user_count_by_heading
      budget.headings.map do |heading|
        [heading.name, headings_stats[heading.id][:total_participants_vote_phase]]
      end.select { |_, count| count > 0 }.sort
    end
end
