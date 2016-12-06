require 'rails_helper'

feature 'Admin polls' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario 'Index empty', :js do
    visit admin_root_path

    click_link "Polls"
    within('#polls_menu') do
      click_link "Polls"
    end

    expect(page).to have_content "There are no polls"
  end

  scenario 'Index', :js do
    3.times { create(:poll) }

    visit admin_root_path

    click_link "Polls"
    within('#polls_menu') do
      click_link "Polls"
    end

    expect(page).to have_css ".poll", count: 3

    polls = Poll.all
    polls.each do |poll|
      within("#poll_#{poll.id}") do
        expect(page).to have_content poll.name
      end
    end
    expect(page).to_not have_content "There are no polls"
  end

  scenario 'Show' do
    poll = create(:poll)

    visit admin_polls_path
    click_link poll.name

    expect(page).to have_content poll.name
  end

  scenario "Create" do
    visit admin_polls_path
    click_link "Create poll"

    fill_in "poll_name", with: "Upcoming poll"
    click_button "Create poll"

    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Upcoming poll"
  end

  scenario "Edit" do
    poll = create(:poll)

    visit admin_poll_path(poll)
    click_link "Edit"

    fill_in "poll_name", with: "Next Poll"
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

  context "Booths" do

    context "Poll show" do

      scenario "No booths", :js do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Booths (0)"

        expect(page).to have_content "There are no booths in this poll."
      end

      scenario "Booth list", :js do
        poll = create(:poll)
        3.times { create(:poll_booth, polls: [poll]) }

        visit admin_poll_path(poll)
        click_link "Booths (3)"

        expect(page).to have_css ".booth", count: 3

        booths = Poll::Booth.all
        booths.each do |booth|
          within("#booth_#{booth.id}") do
            expect(page).to have_content booth.name
            expect(page).to have_content booth.location
          end
        end
        expect(page).to_not have_content "There are no booths"
      end
    end
  end

  context "Officers" do

    context "Poll show" do

      scenario "No officers", :js do
        poll = create(:poll)
        visit admin_poll_path(poll)
        click_link "Officers (0)"

        expect(page).to have_content "There are no officers assigned to this poll"
      end

      scenario "Officer list", :js do
        poll = create(:poll)
        booth = create(:poll_booth, polls: [poll])

        booth.booth_assignments.each do |booth_assignment|
          3.times {create(:poll_officer_assignment, booth_assignment: booth_assignment) }
        end

        visit admin_poll_path(poll)

        click_link "Officers (3)"

        expect(page).to have_css ".officer", count: 3

        officers = Poll::Officer.all
        officers.each do |officer|
          within("#officer_#{officer.id}") do
            expect(page).to have_content officer.name
            expect(page).to have_content officer.email
          end
        end
        expect(page).to_not have_content "There are no officers assigned to this poll"
      end
    end
  end

end