require "rails_helper"

describe Legislation::Proposals::VotesComponent do
  let(:proposal) { create(:legislation_proposal, title: "Require wearing masks at home") }
  let(:component) { Legislation::Proposals::VotesComponent.new(proposal) }

  describe "Agree and disagree links" do
    it "is not shown when the proposals phase isn't open" do
      proposal.process.update!(
        proposals_phase_start_date: 2.days.ago,
        proposals_phase_end_date: Date.yesterday
      )

      sign_in(create(:user))
      render_inline component

      expect(page).not_to have_content "I agree"
      expect(page).not_to have_content "I disagree"
    end

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
      expect(page).to have_link "I agree with Require wearing masks at home"
      expect(page).to have_link "I disagree", title: "I disagree"
      expect(page).to have_link "I don't agree with Require wearing masks at home"
      expect(page).not_to have_content "You must sign in or sign up to continue."
    end
  end
end
