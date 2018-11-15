require "rails_helper"

feature "Admin proposals" do
  background do
    login_as create(:administrator).user
  end

  scenario "Index" do
    create(:proposal, title: "Make Pluto a planet again")

    visit admin_root_path
    within("#side_menu") { click_link "Proposals" }

    expect(page).to have_content "Make Pluto a planet again"
  end
end
