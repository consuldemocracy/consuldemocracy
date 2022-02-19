require "rails_helper"

describe Legislation::Proposals::VotesComponent do
  let(:proposal) { create(:legislation_proposal, title: "Require wearing masks at home") }
  let(:component) { Legislation::Proposals::VotesComponent.new(proposal) }

  describe "Agree and disagree buttons" do
    it "is not shown when the proposals phase isn't open" do
      proposal.process.update!(
        proposals_phase_start_date: 2.days.ago,
        proposals_phase_end_date: Date.yesterday
      )

      sign_in(create(:user))
      render_inline component

      expect(page).not_to have_button "I agree", disabled: :all
      expect(page).not_to have_button "I disagree", disabled: :all
    end

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
      expect(page).to have_button "I agree with Require wearing masks at home"
      expect(page).to have_button "I disagree", title: "I disagree"
      expect(page).to have_button "I don't agree with Require wearing masks at home"
      expect(page).not_to have_content "You must sign in or sign up to continue."
    end

    it "does not include result percentages" do
      create(:vote, votable: proposal)
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
