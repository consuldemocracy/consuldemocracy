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

  scenario 'Create a poll', :js do
    click_link 'Polls'
    click_link 'Create poll'

    start_date = 1.week.from_now
    end_date = 2.weeks.from_now

    fill_in "poll_name", with: 'Upcoming poll'
    fill_in 'poll_starts_at', with: start_date.strftime('%d/%m/%Y')
    fill_in 'poll_ends_at', with: end_date.strftime('%d/%m/%Y')
    fill_in 'poll_description', with: "Upcomming poll's description. This poll..."

    expect(page).not_to have_css('#poll_results_enabled')
    expect(page).not_to have_css('#poll_stats_enabled')

    click_link 'Add question'

    fill_in 'Question', with: 'First question'

    click_link 'Add answer'
    fill_in 'Title', with: 'First answer'

    click_button 'Create poll'

    expect(page).to have_content 'Poll created successfully'
    expect(page).to have_content 'Upcoming poll'
    expect(page).to have_content I18n.l(start_date.to_date)
  end

  scenario 'Create a poll redirects back to form when invalid data', js: true do
    click_link 'Polls'
    click_link 'Create poll'

    click_button 'Create poll'

    expect(page).to have_content('New poll')
  end

  scenario 'Edit poll is allowed for upcoming polls' do
    poll = create(:poll, :incoming, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content('Edit survey')

      click_link 'Edit survey'
    end

    click_button 'Update poll'

    expect(page).to have_content 'Poll updated successfully'
  end

  scenario 'Edit poll redirects back when invalid data', js: true do
    poll = create(:poll, :incoming, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content('Edit survey')

      click_link 'Edit survey'
    end

    fill_in "poll_name", with: ''

    click_button 'Update poll'

    expect(page).to have_content('Edit poll')
  end

  scenario 'Edit poll is not allowed for current polls' do
    poll = create(:poll, :current, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).not_to have_content('Edit survey')
    end
  end

  scenario 'Edit poll is not allowed for expired polls' do
    poll = create(:poll, :expired, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).not_to have_content('Edit survey')
    end
  end

  scenario 'View results not available for upcoming polls' do
    poll = create(:poll, :incoming, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).not_to have_content('View results')
    end
  end

  scenario 'View results available for current polls' do
    poll = create(:poll, :current, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content('View results')
    end
  end

  scenario 'View results available for expired polls' do
    poll = create(:poll, :expired, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content('View results')
    end
  end

  scenario 'View results redirects to results in public zone', js: true do
    poll = create(:poll, :expired, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      click_link 'View results'
    end

    page.driver.browser.switch_to.window page.driver.browser.window_handles.last do
      expect(page.current_path).to eq(results_poll_path(poll))
    end
  end

  scenario 'Poll card' do
     poll = create(:poll, :expired, related: proposal)
    
    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content(I18n.l(poll.starts_at.to_date))
      expect(page).to have_content(I18n.l(poll.ends_at.to_date))
      expect(page).to have_link(poll.title)
    end
  end
end
