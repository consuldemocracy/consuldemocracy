require "rails_helper"

describe "Commenting debates" do
  let(:user)   { create(:user) }
  let(:debate) { create(:debate) }

  it_behaves_like "flaggable", :debate_comment

  scenario "Reply to reply" do
    create(:comment, commentable: debate, body: "Any estimates?")

    login_as(create(:user))
    visit debate_path(debate)

    within ".comment", text: "Any estimates?" do
      click_link "Reply"
      fill_in "Leave your comment", with: "It will be done next week."
      click_button "Publish reply"
    end

    within ".comment .comment", text: "It will be done next week" do
      click_link "Reply"
      fill_in "Leave your comment", with: "Probably if government approves."
      click_button "Publish reply"

      expect(page).not_to have_css ".comment-form"

      within ".comment" do
        expect(page).to have_content "Probably if government approves."
      end
    end
  end

  scenario "Show comment when the author is hidden" do
    create(:comment, body: "This is pointless", commentable: debate, author: create(:user, :hidden))

    visit debate_path(debate)

    within ".comment", text: "This is pointless" do
      expect(page).to have_content "User deleted"
    end
  end

  scenario "Submit button is disabled after clicking" do
    debate = create(:debate)
    login_as(user)
    visit debate_path(debate)

    fill_in "Leave your comment", with: "Testing submit button!"
    click_button "Publish comment"

    expect(page).to have_button "Publish comment", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish comment", disabled: false
  end
end
