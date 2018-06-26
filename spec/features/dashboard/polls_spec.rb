require 'rails_helper'

feature 'Polls' do
  let!(:proposal) { create(:proposal, :draft) }

  before do
    login_as(proposal.author)
    visit proposal_dashboard_index_path(proposal)
  end

  scenario 'Has a link to polls feature' do
    expect(page).to have_link('Polls')
  end

  scenario 'Initially there are no polls' do
    click_link 'Polls'
    expect(page).to have_content('There are no polls coming up.')
  end

  scenario 'Create a poll', :js do
    click_link 'Polls'
    click_link 'Create poll'

    start_date = 1.week.from_now
    end_date = 2.weeks.from_now

    fill_in "poll_name", with: "Upcoming poll"
    fill_in 'poll_starts_at', with: start_date.strftime("%d/%m/%Y")
    fill_in 'poll_ends_at', with: end_date.strftime("%d/%m/%Y")
    fill_in 'poll_summary', with: "Upcoming poll's summary. This poll..."
    fill_in 'poll_description', with: "Upcomming poll's description. This poll..."

    expect(page).not_to have_css("#poll_results_enabled")
    expect(page).not_to have_css("#poll_stats_enabled")

    click_link 'Add question'

    fill_in 'Question', with: 'First question'

    click_link 'Add answer'
    fill_in 'Title', with: 'First answer'

    click_button "Create poll"

    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Upcoming poll"
    expect(page).to have_content "First question"
    expect(page).to have_content I18n.l(start_date.to_date)
    expect(page).to have_content I18n.l(end_date.to_date)
    expect(page).to have_link('Results')
  end

  scenario 'Update a poll', :js do
    poll = create(:poll, related: proposal)

    click_link 'Polls'

    expect(page).to have_content(poll.name)

    within("#poll_#{poll.id}") do
      click_link 'Edit'
    end

    fill_in "poll_name", with: "Updated upcoming poll"

    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"
    expect(page).to have_content "Updated upcoming poll"
  end
end
