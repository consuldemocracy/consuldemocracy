class Budgets::Ballot::BallotComponent < ApplicationComponent
  attr_reader :ballot

  def initialize(ballot)
    @ballot = ballot
  end

  def budget
    ballot.budget
  end
end
