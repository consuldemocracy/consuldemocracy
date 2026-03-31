require "rails_helper"

describe Budgets::Investments::VotesComponent do
  describe "vote link" do
    context "when investment shows votes" do
      let(:heading) { create(:budget_heading) }
      let(:investment) { create(:budget_investment, heading: heading) }
      let(:component) { Budgets::Investments::VotesComponent.new(investment) }

      before { allow(investment).to receive(:should_show_votes?).and_return(true) }

      it "hides button when enough support reached" do
        sign_in(create(:user))

        render_inline component
        expect(page).to have_button

        heading.required_support = 1
        render_inline component
        expect(page).to have_button

        investment.vote_by(voter: create(:user), vote: "yes")
        render_inline component
        expect(page).not_to have_button
      end
    end
  end
end
