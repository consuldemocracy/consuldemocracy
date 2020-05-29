require "rails_helper"

describe "Admin comments" do
  before do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Index" do
    create(:comment, body: "Everything is awesome")

    visit admin_root_path
    within("#side_menu") { click_link "Comments" }

    expect(page).to have_content "Everything is awesome"
  end
end
