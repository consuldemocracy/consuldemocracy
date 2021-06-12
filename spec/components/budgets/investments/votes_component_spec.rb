require "rails_helper"

describe Budgets::Investments::VotesComponent, type: :component do
  describe "vote link" do
    context "when investment shows votes" do
      let(:investment) { create(:budget_investment, title: "Renovate sidewalks in Main Street") }
      let(:component) do
        Budgets::Investments::VotesComponent.new(investment, investment_votes: [], vote_url: "/")
      end

      before { allow(investment).to receive(:should_show_votes?).and_return(true) }

      it "displays a link to support the investment to identified users" do
        allow(controller).to receive(:current_user).and_return(create(:user))

        render_inline component

        expect(page).to have_link count: 1
        expect(page).to have_link "Support", title: "Support this project"
        expect(page).to have_link "Support Renovate sidewalks in Main Street"
      end

      it "does not display link to support the investment to unidentified users" do
        allow(controller).to receive(:current_user).and_return(nil)

        render_inline component

        expect(page).not_to have_link "Support"
        expect(page).to have_content "Support"
      end
    end
  end
end
