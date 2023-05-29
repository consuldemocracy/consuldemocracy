require "rails_helper"

describe Shared::InFavorAgainstComponent do
  let(:debate) { create(:debate) }
  let(:component) { Shared::InFavorAgainstComponent.new(debate) }
  let(:user) { create(:user) }

  describe "Agree and disagree buttons" do
    it "does not include result percentages" do
      create(:vote, votable: debate)
      sign_in(user)

      render_inline component

      expect(page).to have_button count: 2
      expect(page).to have_button "I agree"
      expect(page).to have_button "I disagree"
      expect(page).not_to have_button text: "%"
      expect(page).not_to have_button text: "100"
      expect(page).not_to have_button text: "0"
    end

    describe "aria-pressed attribute" do
      it "is true when the in-favor button is pressed" do
        debate.register_vote(user, "yes")
        sign_in(user)

        render_inline component

        expect(page.find(".in-favor")).to have_css "button[aria-pressed='true']"
        expect(page.find(".against")).to have_css "button[aria-pressed='false']"
      end

      it "is true when the against button is pressed" do
        debate.register_vote(user, "no")
        sign_in(user)

        render_inline component

        expect(page.find(".in-favor")).to have_css "button[aria-pressed='false']"
        expect(page.find(".against")).to have_css "button[aria-pressed='true']"
      end

      it "is false when neither the 'in-favor' button nor the 'against' button are pressed" do
        sign_in(user)

        render_inline component

        expect(page.find(".in-favor")).to have_css "button[aria-pressed='false']"
        expect(page.find(".against")).to have_css "button[aria-pressed='false']"
      end
    end
  end
end
