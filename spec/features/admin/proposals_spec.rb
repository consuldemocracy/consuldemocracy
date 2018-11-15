require "rails_helper"

feature "Admin proposals" do
  background do
    login_as create(:administrator).user
  end

  it_behaves_like "admin_milestoneable",
                  :proposal,
                  "admin_proposal_path"

  context "Index" do
    scenario "Search" do
      create(:proposal, title: "Make Pluto a planet again")
      create(:proposal, title: "Build a monument to honour CONSUL developers")

      visit admin_root_path
      within("#side_menu") { click_link "Proposals" }

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).to have_content "Build a monument"

      fill_in "search", with: "Pluto"
      click_button "Search"

      expect(page).to have_content "Make Pluto a planet again"
      expect(page).not_to have_content "Build a monument"
    end
  end

  scenario "Show" do
    create(:proposal, title: "Create a chaotic future", summary: "Chaos isn't controlled")

    visit admin_proposals_path
    click_link "Create a chaotic future"

    expect(page).to have_content "Chaos isn't controlled"
  end
end
