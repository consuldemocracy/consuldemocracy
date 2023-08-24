require "rails_helper"

describe "Commenting proposals" do
  let(:user) { create :user }
  let(:proposal) { create :proposal }

  scenario "Show order links only if there are comments" do
    visit proposal_path(proposal)

    within "#tab-comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: proposal, user: user)
    visit proposal_path(proposal)

    within "#tab-comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
