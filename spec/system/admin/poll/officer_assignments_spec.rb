require "rails_helper"

describe "Officer Assignments", :admin do
  scenario "Index" do
    poll = create(:poll)

    create(:poll_officer, name: "Bubbles", polls: [poll])
    create(:poll_officer, name: "Blossom", polls: [poll])
    create(:poll_officer, name: "Buttercup")

    visit admin_poll_path(poll)

    click_link "Officers (2)"

    within("#officer_assignments") do
      expect(page).to have_content "Bubbles"
      expect(page).to have_content "Blossom"
      expect(page).not_to have_content "Buttercup"
    end
  end

  scenario "Search", :js do
    poll = create(:poll)

    create(:poll_officer, name: "John Snow", polls: [poll])
    create(:poll_officer, name: "John Silver", polls: [poll])
    create(:poll_officer, name: "John Edwards")

    visit admin_poll_path(poll)

    click_link "Officers (2)"

    fill_in "search-officers", with: "John"
    click_button "Search"

    within("#search-officers-results") do
      expect(page).to have_content "John Snow"
      expect(page).to have_content "John Silver"
      expect(page).not_to have_content "John Edwards"
    end
  end
end
