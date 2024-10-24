require "rails_helper"

describe Shared::ParticipationNotAllowedComponent do
  let(:votable) { create(:proposal) }

  context "Without cannot vote text" do
    let(:component) { Shared::ParticipationNotAllowedComponent.new(votable, cannot_vote_text: nil) }

    it "asks anonymous users to sign in or sign up" do
      render_inline component

      expect(page).to have_content "You must sign in or sign up to continue"
      expect(page).to have_link "sign in"
      expect(page).to have_link "sign up"
    end

    it "says voting is not allowed to organizations" do
      sign_in(create(:organization, user: create(:user, :level_two)).user)

      render_inline component

      expect(page).to have_content "Organizations are not permitted to vote"
      expect(page).not_to have_link "sign in", visible: :all
      expect(page).not_to have_link "sign up", visible: :all
    end

    it "is not rendered to regular users" do
      sign_in(create(:user))

      render_inline component

      expect(page).not_to be_rendered
    end
  end

  context "With cannot vote text" do
    let(:component) { Shared::ParticipationNotAllowedComponent.new(votable, cannot_vote_text: "Too old") }

    it "ignores the text and asks anonymous users to sign in or sign up" do
      render_inline component

      expect(page).to have_content "You must sign in or sign up to continue"
      expect(page).to have_link "sign in"
      expect(page).to have_link "sign up"
      expect(page).not_to have_content "Too old"
    end

    it "ignores the text and says voting is not allowed to organizations" do
      sign_in(create(:organization, user: create(:user, :level_two)).user)

      render_inline component

      expect(page).to have_content "Organizations are not permitted to vote"
      expect(page).not_to have_link "sign in", visible: :all
      expect(page).not_to have_link "sign up", visible: :all
      expect(page).not_to have_content "Too old"
    end

    it "renders the cannot vote text to regular users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_content "Too old"
      expect(page).not_to have_content "Organizations are not permitted to vote"
      expect(page).not_to have_link "sign in", visible: :all
      expect(page).not_to have_link "sign up", visible: :all
    end
  end
end
