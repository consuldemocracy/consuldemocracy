require 'rails_helper'

feature 'Admin polls' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Index empty' do
    visit admin_root_path
    within('#side_menu') do
      click_link "Polls"
    end

    expect(page).to have_content "There are no polls"
  end

  scenario 'Index' do
    3.times { create(:poll) }

    visit admin_root_path

    within('#side_menu') do
      click_link "Polls"
    end

    expect(page).to have_css ".poll", count: 3

    Poll.all.each do |poll|
      within("#poll_#{poll.id}") do
        expect(page).to have_content poll.name
#expect(page).to have_content "Status/Dates" - Hardcoded
      end
    end
    expect(page).to_not have_content "There are no polls"
  end

  scenario 'Show' do
    poll = create(:poll)

    visit admin_polls_path
    click_link poll.name

    expect(page).to have_content poll.name
#expect(page).to have_content "Status/Dates" - Hardcoded
#expect(page).to have_content "REFNUM" - Hardcoded
  end

  scenario "Create" do
    visit admin_polls_path
    click_link "Create poll"

    fill_in "poll_name", with: "Upcoming poll"
#fill_in reference_number - Hardcoded
#fill_in open_date - Hardcoded
#fill_in close_date - Hardcoded
    click_button "Create poll"
    expect(page).to have_content "Poll created successfully"

    expect(page).to have_content "Upcoming poll"
  end

  scenario "Edit" do
    poll = create(:poll)

    visit admin_poll_path(poll)
    click_link "Edit"
save_and_open_page
    fill_in "poll_name", with: "Next Poll"
#fill_in reference_number - Hardcoded
#fill_in open_date - Hardcoded
#fill_in close_date - Hardcoded
    click_button "Update poll"
    expect(page).to have_content "Poll updated successfully"

    expect(page).to have_content "Next Poll"
  end

  scenario 'Edit from index' do
    poll = create(:poll)
    visit admin_polls_path

    within("#poll_#{poll.id}") do
      click_link "Edit"
    end

    expect(current_path).to eq(edit_admin_poll_path(poll))
  end

end