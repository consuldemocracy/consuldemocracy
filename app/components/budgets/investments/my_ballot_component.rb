class Budgets::Investments::MyBallotComponent < ApplicationComponent
  attr_reader :ballot, :heading, :investment_ids, :assigned_heading
  delegate :can?, :heading_link, to: :helpers

  def initialize(ballot:, heading:, investment_ids:, assigned_heading: nil)
    @ballot = ballot
    @heading = heading
    @investment_ids = investment_ids
    @assigned_heading = assigned_heading
  end

  def render?
    heading && can?(:show, ballot)
  end

  private

    def budget
      ballot.budget
    end
end
