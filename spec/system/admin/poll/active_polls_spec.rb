require "rails_helper"

describe "Admin Active polls", :admin do
  scenario "Add" do
    visit admin_polls_path
    click_link "Polls description"

    expect(page).to have_ckeditor "Description", with: ""

    fill_in_ckeditor "Description", with: "Active polls description"
    click_button "Save"

    expect(page).to have_content "Polls description updated successfully."

    click_link "Polls description"

    expect(page).to have_ckeditor "Description", with: "Active polls description"
  end

  scenario "Edit" do
    create(:active_poll, description_en: "Old description")

    visit polls_path
    within ".polls-description" do
      expect(page).to have_content "Old description"
    end

    visit edit_admin_active_polls_path
    fill_in_ckeditor "Description", with: "New description"
    click_button "Save"

    expect(page).to have_content "Polls description updated successfully."

    visit polls_path
    within ".polls-description" do
      expect(page).not_to have_content "Old description"
      expect(page).to have_content "New description"
    end
  end
end
