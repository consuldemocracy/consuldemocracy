require "rails_helper"

describe Debates::VotesComponent do
  let(:debate) { create(:debate, title: "What about the 2030 agenda?") }
  let(:component) { Debates::VotesComponent.new(debate) }

  describe "Agree and disagree buttons" do
    it "is shown to anonymous users alongside a reminder to sign in" do
      render_inline component

      expect(page).to have_button "I agree"
      expect(page).to have_button "I disagree"
      expect(page).to have_content "You must sign in or sign up to continue."
    end

    it "is shown to identified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button count: 2
      expect(page).to have_button "I agree", title: "I agree"
      expect(page).to have_button "I agree with What about the 2030 agenda?"
      expect(page).to have_button "I disagree", title: "I disagree"
      expect(page).to have_button "I don't agree with What about the 2030 agenda?"
      expect(page).not_to have_content "You must sign in or sign up to continue."
    end

    it "does not include result percentages" do
      create(:vote, votable: debate)
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button count: 2
      expect(page).to have_button "I agree"
      expect(page).to have_button "I disagree"
      expect(page).not_to have_button text: "%"
      expect(page).not_to have_button text: "100"
      expect(page).not_to have_button text: "0"
    end
  end
end
