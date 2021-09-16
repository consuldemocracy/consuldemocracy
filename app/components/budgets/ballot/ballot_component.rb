class Budgets::Ballot::BallotComponent < ApplicationComponent
  attr_reader :ballot

  def initialize(ballot)
    @ballot = ballot
  end

  def budget
    ballot.budget
  end

  private

    def ballot_groups
      ballot.groups.sort_by_name
    end

    def no_balloted_groups
      budget.groups.sort_by_name - ballot.groups
    end
end
