require "rails_helper"

describe "Commenting debates" do
  let(:user)   { create :user }
  let(:debate) { create :debate }

  scenario "Show order links only if there are comments" do
    visit debate_path(debate)

    within "#comments" do
      expect(page).not_to have_link "Most voted"
      expect(page).not_to have_link "Newest first"
      expect(page).not_to have_link "Oldest first"
    end

    create(:comment, commentable: debate, user: user)
    visit debate_path(debate)

    within "#comments" do
      expect(page).to have_link "Most voted"
      expect(page).to have_link "Newest first"
      expect(page).to have_link "Oldest first"
    end
  end
end
