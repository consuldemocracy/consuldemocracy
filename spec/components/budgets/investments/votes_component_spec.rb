require "rails_helper"

describe Budgets::Investments::VotesComponent do
  describe "vote link" do
    context "when investment shows votes" do
      let(:investment) { create(:budget_investment, title: "Renovate sidewalks in Main Street") }
      let(:component) { Budgets::Investments::VotesComponent.new(investment) }

      before { allow(investment).to receive(:should_show_votes?).and_return(true) }

      it "displays a button to support the investment to identified users" do
        sign_in(create(:user))

        render_inline component

        expect(page).to have_button count: 1
        expect(page).to have_button "Support", title: "Support this project", disabled: false
        expect(page).to have_button "Support Renovate sidewalks in Main Street"
      end

      it "renders the support button and a reminder to sign in to unidentified users" do
        render_inline component

        expect(page).to have_button count: 1, disabled: :all
        expect(page).to have_button "Support"
        expect(page).to have_content "You must sign in or sign up to continue."
      end

      describe "button to remove support" do
        let(:user) { create(:user) }

        before do
          user.up_votes(investment)
          sign_in(user)
        end

        it "is shown when the setting is enabled" do
          Setting["feature.remove_investments_supports"] = true

          render_inline component

          expect(page).to have_button count: 1, disabled: :all
          expect(page).to have_button "Remove your support"
          expect(page).to have_button "Remove your support to Renovate sidewalks in Main Street"
        end

        it "is not shown when the setting is disabled" do
          Setting["feature.remove_investments_supports"] = false

          render_inline component

          expect(page).not_to have_button disabled: :all
        end
      end
    end
  end
end
