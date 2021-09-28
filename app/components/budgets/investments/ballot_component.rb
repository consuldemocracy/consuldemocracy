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
end
