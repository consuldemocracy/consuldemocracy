require "rails_helper"

describe Budgets::Investments::MyBallotComponent do
  let(:user) { create(:user, :level_two) }
  let(:budget) { create(:budget, :balloting) }
  let(:ballot) { create(:budget_ballot, user: user, budget: budget) }
  let(:heading) { create(:budget_heading, budget: budget) }

  before do
    vc_test_request.session[:ballot_referer] = "/"
    sign_in(user)
  end

  it "sorts investments by ballot lines" do
    ["B letter", "A letter", "C letter"].each do |title|
      ballot.add_investment(create(:budget_investment, :selected, heading: heading, title: title))
    end

    render_inline Budgets::Investments::MyBallotComponent.new(
      ballot: ballot,
      heading: heading,
      investment_ids: []
    )

    expect("B letter").to appear_before "A letter"
    expect("A letter").to appear_before "C letter"
  end
end
