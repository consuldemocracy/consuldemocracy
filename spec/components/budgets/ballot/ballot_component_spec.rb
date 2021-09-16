require "rails_helper"

describe Budgets::Ballot::BallotComponent do
  include Rails.application.routes.url_helpers
  before { request.session[:ballot_referer] = "/" }

  describe "link to group" do
    let(:budget) { create(:budget, :balloting) }
    let(:ballot) { create(:budget_ballot, user: create(:user), budget: budget) }

    it "displays links to vote on groups with no investments voted yet" do
      group = create(:budget_group, budget: budget)

      render_inline Budgets::Ballot::BallotComponent.new(ballot)

      expect(page).to have_link "You have not voted on this group yet, go vote!", href: budget_group_path(budget, group)
    end
  end
end
