require "rails_helper"

feature "Admin Active polls" do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  it_behaves_like "translatable",
                  "active_poll",
                  "edit_admin_active_polls_path",
                  [],
                  { "description" => :ckeditor }

  scenario "Add", :js do
    expect(ActivePoll.first).to be nil

    visit admin_polls_path
    click_link "Polls description"

    fill_in_ckeditor "Description", with: "Active polls description"
    click_button "Save"

    expect(page).to have_content "Polls description updated successfully."
    expect(ActivePoll.first.description).to eq "<p>Active polls description</p>\r\n"
  end

  scenario "Edit", :js do
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
