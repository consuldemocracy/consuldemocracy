require "rails_helper"

describe Debates::VotesComponent do
  let(:debate) { create(:debate, title: "What about the 2030 agenda?") }
  let(:component) { Debates::VotesComponent.new(debate) }

  describe "Agree and disagree links" do
    it "is shown as plain text to anonymous users" do
      render_inline component

      expect(page).to have_content "I agree"
      expect(page).to have_content "I disagree"
      expect(page).to have_content "You must sign in or sign up to continue."
      expect(page).not_to have_link "I agree"
      expect(page).not_to have_link "I disagree"
    end

    it "is shown to identified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_link count: 2
      expect(page).to have_link "I agree", title: "I agree"
      expect(page).to have_link "I disagree", title: "I disagree"
      expect(page).not_to have_content "You must sign in or sign up to continue."
    end
  end
end
