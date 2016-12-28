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

    start_date = 1.week.from_now
    end_date = 2.weeks.from_now

    fill_in "poll_name", with: "Upcoming poll"
    fill_in 'poll_starts_at', with: start_date.strftime("%d/%m/%Y")
    fill_in 'poll_ends_at', with: end_date.strftime("%d/%m/%Y")
    click_button "Create poll"

    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Upcoming poll"
    expect(page).to have_content I18n.l(start_date.to_date)
    expect(page).to have_content I18n.l(end_date.to_date)
  end

  scenario "Edit" do
    poll = create(:poll)

    visit admin_poll_path(poll)
    click_link "Edit"

    end_date = 1.year.from_now

    fill_in "poll_name", with: "Next Poll"
    fill_in 'poll_ends_at', with: end_date.strftime("%d/%m/%Y")
    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"
    expect(page).to have_content "Next Poll"
    expect(page).to have_content I18n.l(end_date.to_date)
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

        expect(page).to have_content "There are no booths assigned to this poll."
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
        expect(page).to_not have_content "There are no booths assigned to this poll."
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

  context "Questions" do
    context "Poll show" do

      scenario "Question list", :js do
        poll = create(:poll)
        question = create(:poll_question, poll: poll)
        other_question = create(:poll_question)

        visit admin_poll_path(poll)

        click_link "Questions (1)"

        expect(page).to have_content question.title
        expect(page).to_not have_content other_question.title
        expect(page).to_not have_content "There are no questions assigned to this poll"
      end

      scenario 'Add question to poll', :js do
        poll = create(:poll)
        question = create(:poll_question, poll: nil, title: 'Should we rebuild the city?')

        visit admin_poll_path(poll)
        within('#poll-resources') do
          click_link 'Questions (0)'
        end

        expect(page).to have_content 'There are no questions assigned to this poll'

        fill_in 'search-questions', with: 'rebuild'
        click_button 'Search'

        within('#search-questions-results') do
          click_link 'Include question'
        end

        expect(page).to have_content 'Question added to this poll'

        visit admin_poll_path(poll)
        within('#poll-resources') do
          click_link 'Questions (1)'
        end

        expect(page).to_not have_content 'There are no questions assigned to this poll'
        expect(page).to have_content question.title
      end

      scenario 'Remove question from poll', :js do
        poll = create(:poll)
        question = create(:poll_question, poll: poll)

        visit admin_poll_path(poll)
        within('#poll-resources') do
          click_link 'Questions (1)'
        end

        expect(page).to_not have_content 'There are no questions assigned to this poll'
        expect(page).to have_content question.title

        within("#poll_question_#{question.id}") do
          click_link 'Remove question from poll'
        end

        expect(page).to have_content 'Question removed from this poll'

        visit admin_poll_path(poll)
        within('#poll-resources') do
          click_link 'Questions (0)'
        end

        expect(page).to have_content 'There are no questions assigned to this poll'
        expect(page).to_not have_content question.title
      end

    end
  end


end