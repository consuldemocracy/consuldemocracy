require "rails_helper"

describe "Tags" do
  scenario "Create with custom tags" do
    user = create(:user)
    login_as(user)

    visit new_proposal_path
    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "This is very important because..."
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"
    fill_in "Tags", with: "Economía, Hacienda"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "Economía"
    expect(page).to have_content "Hacienda"
  end

  scenario "Category with category tags" do
    create(:tag, :category, name: "Education")
    create(:tag, :category, name: "Health")

    login_as(create(:user))
    visit new_proposal_path

    fill_in_new_proposal_title with: "Help refugees"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "A description with enough characters"
    fill_in "External video URL", with: "https://www.youtube.com/watch?v=Ae6gQmhaMn4"
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"

    find(".js-add-tag-link", text: "Education").click
    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_css "h1", exact_text: "Help refugees"

    within ".tags" do
      expect(page).to have_content "Education"
      expect(page).not_to have_content "Health"
    end
  end

  scenario "Create with too many tags" do
    user = create(:user)
    login_as(user)

    visit new_proposal_path
    fill_in_new_proposal_title with: "Title"
    fill_in_ckeditor "Proposal text", with: "Description"

    fill_in "Tags", with: "Impuestos, Economía, Hacienda, Sanidad, Educación, Política, Igualdad"

    click_button "Create proposal"

    expect(page).to have_content error_message
    expect(page).to have_content "tags must be less than or equal to 6"
  end

  scenario "Create with dangerous strings" do
    author = create(:user)
    login_as(author)

    visit new_proposal_path

    fill_in_new_proposal_title with: "A test of dangerous strings"
    fill_in "Proposal summary", with: "In summary, what we want is..."
    fill_in_ckeditor "Proposal text", with: "A description suitable for this test"
    fill_in "Full name of the person submitting the proposal", with: "Isabel Garcia"

    fill_in "Tags", with: "user_id=1, &a=3, <script>alert('hey');</script>"

    click_button "Create proposal"

    expect(page).to have_content "Proposal created successfully."
    click_link "No, I want to publish the proposal"
    click_link "Not now, go to my proposal"

    expect(page).to have_content "user_id1"
    expect(page).to have_content "a3"
    expect(page).to have_content "scriptalert('hey');script"
    expect(page.html).not_to include "user_id=1, &a=3, <script>alert('hey');</script>"
  end
end
