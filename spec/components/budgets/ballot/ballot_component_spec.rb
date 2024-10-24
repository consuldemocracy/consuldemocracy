require "rails_helper"

describe Budgets::Ballot::BallotComponent do
  include Rails.application.routes.url_helpers
  before { vc_test_request.session[:ballot_referer] = "/" }
  let(:budget) { create(:budget, :balloting) }
  let(:ballot) { create(:budget_ballot, user: create(:user), budget: budget) }

  describe "link to group" do
    let(:group) { create(:budget_group, budget: budget) }

    context "group with a single heading" do
      let!(:heading) { create(:budget_heading, group: group, price: 1000) }

      it "displays a link to vote investments when there aren't any investments in the ballot" do
        render_inline Budgets::Ballot::BallotComponent.new(ballot)

        expect(page).to have_link "You have not voted on this group yet, go vote!",
                                  href: budget_investments_path(budget, heading_id: heading.id)
      end

      it "displays a link to continue voting when there are investments in the ballot" do
        ballot.investments << create(:budget_investment, :selected, heading: heading, price: 200)

        render_inline Budgets::Ballot::BallotComponent.new(ballot)

        expect(page).to have_link "Still available to you €800",
                                  href: budget_investments_path(budget, heading_id: heading.id)
      end
    end

    context "group with multiple headings" do
      let!(:heading) { create(:budget_heading, group: group, price: 1000) }
      before { create(:budget_heading, group: group) }

      it "displays a link to vote on a heading when there aren't any investments in the ballot" do
        render_inline Budgets::Ballot::BallotComponent.new(ballot)

        expect(page).to have_link "You have not voted on this group yet, go vote!",
                                  href: budget_group_path(budget, group)
      end

      it "displays a link to change the heading when there are invesments in the ballot" do
        ballot.investments << create(:budget_investment, :selected, heading: heading, price: 200)

        render_inline Budgets::Ballot::BallotComponent.new(ballot)

        expect(page).to have_link "Still available to you €800",
                                  href: budget_group_path(budget, group)
      end
    end
  end

  it "sorts investments by ballot lines" do
    ["B letter", "A letter", "C letter"].each do |title|
      ballot.add_investment(create(:budget_investment, :selected, budget: budget, title: title))
    end

    render_inline Budgets::Ballot::BallotComponent.new(ballot)

    expect("B letter").to appear_before "A letter"
    expect("A letter").to appear_before "C letter"
  end
end
