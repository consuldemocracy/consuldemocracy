require "rails_helper"

describe Proposals::VotesComponent do
  let(:proposal) { create(:proposal, title: "Create a monthly transport ticket") }
  let(:component) { Proposals::VotesComponent.new(proposal) }

  describe "support proposal button" do
    it "is shown to unverified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_button "Support"
    end

    it "is shown to verified users" do
      sign_in(create(:user, :level_two))

      render_inline component

      expect(page).to have_button count: 1
      expect(page).to have_button "Support", title: "Support this proposal"
      expect(page).to have_button "Support Create a monthly transport ticket"
      expect(page).not_to have_content "You have already supported this proposal. Share it!"
    end

    it "is replaced with a success message when the proposal is already supported" do
      sign_in(create(:user, :level_two, votables: [proposal]))

      render_inline component

      expect(page).to have_content "You have already supported this proposal. Share it!"
      expect(page).not_to have_button "Support", disabled: :all
    end
  end

  describe "participation not allowed" do
    it "asks anonymous users to sign in or sign up" do
      render_inline component

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

    it "says only verified users can vote to unverified users" do
      sign_in(create(:user))

      render_inline component

      expect(page).to have_content "Only verified users can vote on proposals"
      expect(page).to have_link "verify your account"
      expect(page).not_to have_link "sign in", visible: :all
      expect(page).not_to have_link "sign up", visible: :all
    end

    it "is not rendered for verified users" do
      sign_in(create(:user, :level_two))

      render_inline component

      expect(page).not_to have_css ".participation-not-allowed"
      expect(page).not_to have_link "verify your account", visible: :all
      expect(page).not_to have_link "sign in", visible: :all
      expect(page).not_to have_link "sign up", visible: :all
    end
  end
end
