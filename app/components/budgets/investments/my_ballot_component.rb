class Budgets::Investments::MyBallotComponent < ApplicationComponent
  attr_reader :ballot, :heading, :investment_ids, :assigned_heading
  delegate :heading_link, to: :helpers

  def initialize(ballot:, heading:, investment_ids:, assigned_heading:)
    @ballot = ballot
    @heading = heading
    @investment_ids = investment_ids
    @assigned_heading = assigned_heading
  end

  private

    def budget
      ballot.budget
    end
end
