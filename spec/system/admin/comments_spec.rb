require "rails_helper"

describe "Admin comments", :admin do
  scenario "Index" do
    create(:comment, body: "Everything is awesome")

    visit admin_root_path
    within("#side_menu") { click_link "Comments" }

    expect(page).to have_content "Everything is awesome"
  end
end
