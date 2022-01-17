require "rails_helper"

describe Budgets::Investments::BallotComponent do
  describe "vote investment button" do
    let(:budget) { create(:budget, :balloting) }
    let(:investment) { create(:budget_investment, :selected, title: "New Sports Center", budget: budget) }
    let(:component) do
      Budgets::Investments::BallotComponent.new(
        investment: investment,
        investment_ids: [],
        ballot: Budget::Ballot.where(budget: budget, user: controller.current_user).first_or_create!
      )
    end

    it "is shown alongside a 'not allowed' message to unverified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button "Vote"
      expect(page).to have_content "Only verified users can vote on investments; verify your account."
    end

    it "is shown to verified users" do
      sign_in(create(:user, :level_two))

      render_inline component

      expect(page).to have_button count: 1
      expect(page).to have_button "Vote", title: "Support this project"
      expect(page).to have_button "Vote New Sports Center"
      expect(page).not_to have_button "Remove vote", disabled: :all
    end

    it "is replaced with a button to remove the vote when the user has already voted" do
      sign_in(create(:user, :level_two, ballot_lines: [investment]))

      render_inline component

      expect(page).to have_button count: 1
      expect(page).to have_button "Remove vote"
      expect(page).to have_button "Remove your vote for New Sports Center"
      expect(page).not_to have_button "Vote", disabled: :all
    end
  end
end
