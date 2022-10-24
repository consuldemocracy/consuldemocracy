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

    def group_path(group)
      if group.multiple_headings?
        budget_group_path(budget, group)
      else
        budget_investments_path(budget, heading_id: group.headings.first)
      end
    end
end
