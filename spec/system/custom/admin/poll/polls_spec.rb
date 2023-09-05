require "rails_helper"

describe "Admin polls", :admin do
  scenario "Create" do
    travel_to(Time.zone.local(2015, 7, 15, 13, 32, 13))

    visit admin_polls_path
    click_link "Create poll"

    fill_in "Name", with: "Upcoming poll"
    fill_in "Start Date", with: 1.week.from_now
    fill_in "Closing Date", with: 2.weeks.from_now
    fill_in_ckeditor "Summary", with: "Upcoming poll's summary. This poll..."
    fill_in_ckeditor "Description", with: "Upcomming poll's description. This poll..."

    expect(page).not_to have_css("#poll_results_enabled")
    expect(page).not_to have_css("#poll_stats_enabled")
    expect(page).to have_link "Go back", href: admin_polls_path

    click_button "Create poll"

    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Upcoming poll"
    expect(page).to have_content "2015-07-22 13:32"
    expect(page).to have_content "2015-07-29 13:32"

    visit poll_path(id: "upcoming-poll")

    expect(page).to have_content "Upcoming poll"
  end

  context "SDG related list" do
    before do
      Setting["feature.sdg"] = true
      Setting["sdg.process.polls"] = true
    end

    scenario "create poll with sdg related list" do
      visit new_admin_poll_path
      fill_in "Name", with: "Upcoming poll with SDG related content"
      fill_in "Start Date", with: 1.week.from_now
      fill_in "Closing Date", with: 2.weeks.from_now
      fill_in_ckeditor "Summary", with: "Upcoming poll's summary. This poll..."
      fill_in_ckeditor "Description", with: "Upcomming poll's description. This poll..."

      click_sdg_goal(17)
      click_button "Create poll"
      visit admin_polls_path

      within("tr", text: "Upcoming poll with SDG related content") do
        expect(page).to have_css "td", exact_text: "17"
      end
    end
  end
end
