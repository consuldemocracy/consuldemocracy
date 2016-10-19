require 'rails_helper'

feature 'Admin booths' do

  let!(:poll) { create(:poll) }

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Index empty' do
    visit admin_root_path

    within('#side_menu') do
      click_link "Polls"
    end

    click_link poll.name

    expect(page).to have_content "There are no booths in this poll"
  end

  scenario 'Index' do
    3.times { create(:poll_booth, poll: poll) }

    visit admin_root_path

    within('#side_menu') do
      click_link "Polls"
    end

    click_link poll.name

    booths = Poll::Booth.all
    booths.each do |booth|
      within("#booth_#{booth.id}") do
        expect(page).to have_content booth.name
        expect(page).to have_content booth.location
      end
    end
    expect(page).to_not have_content "There are no booths"
  end

  scenario 'Show' do
    booth = create(:poll_booth, poll: poll)

    visit admin_poll_booths_path(poll)
    click_link booth.name

    expect(page).to have_content booth.name
    expect(page).to have_content booth.location
  end

  scenario "Create" do
    visit admin_poll_booths_path(poll)
    click_link "Add booth"

    expect(page).to have_content "Poll #{poll.name}"

    fill_in "poll_booth_name", with: "Upcoming booth"
    fill_in "poll_booth_location", with: "39th Street, number 2, ground floor"
    click_button "Create booth"

    expect(page).to have_content "Booth created successfully"
    expect(page).to have_content "Upcoming booth"
    expect(page).to have_content "39th Street, number 2, ground floor"
  end

  scenario "Edit" do
    booth = create(:poll_booth, poll: poll)

    visit admin_poll_booths_path(poll)

    click_link "Edit"

    expect(page).to have_content "Poll #{poll.name}"

    fill_in "poll_booth_name", with: "Next booth"
    fill_in "poll_booth_location", with: "40th Street, number 1, firts floor"
    click_button "Update booth"

    expect(page).to have_content "Booth updated successfully"
    expect(page).to have_content "Next booth"
    expect(page).to have_content "40th Street, number 1, firts floor"
  end

  scenario 'Edit from index' do
    booth = create(:poll_booth, poll: poll)
    visit admin_poll_booths_path(poll)

    within("#booth_#{booth.id}") do
      click_link "Edit"
    end

    expect(current_path).to eq(edit_admin_poll_booth_path(poll, booth))
  end

end