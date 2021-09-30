class Budgets::Investments::BallotComponent < ApplicationComponent
  attr_reader :investment, :investment_ids, :ballot, :assigned_heading
  delegate :current_user, :heading_link, :link_to_signin, :link_to_signup,
    :link_to_verify_account, to: :helpers

  def initialize(investment:, investment_ids:, ballot:, assigned_heading:)
    @investment = investment
    @investment_ids = investment_ids
    @ballot = ballot
    @assigned_heading = assigned_heading
  end

  private

    def budget
      ballot.budget
    end

    def voted?
      ballot.has_investment?(investment)
    end

    def reason
      @reason ||= investment.reason_for_not_being_ballotable_by(current_user, ballot)
    end

    def vote_aria_label
      t("budgets.investments.investment.add_label", investment: investment.title)
    end

    def remove_vote_aria_label
      t("budgets.ballots.show.remove_label", investment: investment.title)
    end

    def link_to_my_heading
      link_to(investment.heading.name,
              budget_investments_path(budget_id: investment.budget_id,
                                      heading_id: investment.heading_id))
    end

    def link_to_change_ballot
      link_to(t("budgets.ballots.reasons_for_not_balloting.change_ballot"),
              budget_ballot_path(budget))
    end
end
