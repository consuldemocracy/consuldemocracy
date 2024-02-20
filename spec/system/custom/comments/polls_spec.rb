require "rails_helper"

describe "Commenting polls" do
  let(:user) { create :user }
  let(:poll) { create(:poll, author: create(:user)) }

  scenario "Show order links only if there are comments" do
    visit poll_path(poll)

    within "#tab-comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: poll, user: user)
    visit poll_path(poll)

    within "#tab-comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
