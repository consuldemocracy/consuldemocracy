require 'rails_helper'

feature "Proposal's dashboard" do
  let!(:proposal) { create(:proposal, :draft) }

  before do
    login_as(proposal.author)
    visit proposal_dashboard_path(proposal)
  end

  scenario 'Dashboard has a link to my proposal' do
    expect(page).to have_link('My proposal')
  end

  scenario 'My proposal has a link to edit the proposal' do
    expect(page).to have_link('Edit proposal')
  end

  scenario 'My proposal has a link to retire the proposal' do
    expect(page).to have_link('Retire proposal')
  end

  scenario 'My proposal has a link to publish the proposal' do
    expect(page).to have_link('Publish proposal')
  end

  scenario "Publish link dissapears after proposal's publication" do
    click_link 'Publish proposal'
    expect(page).not_to have_link('Publish proposal')
  end

  scenario 'Dashboard progress shows current goal', js: true do
    goal = create(:dashboard_action, :resource, :active, required_supports: proposal.votes_for.size + 1_000)
    future_goal = create(:dashboard_action, :resource, :active, required_supports: proposal.votes_for.size + 2_000)

    visit progress_proposal_dashboard_path(proposal)

    within 'div#goals-section' do
      expect(page).to have_content(goal.title)
      expect(page).not_to have_content(future_goal.title)

      find(:css, '#see_complete_course_link').click

      expect(page).to have_content(goal.title)
      expect(page).to have_content(future_goal.title)
    end
  end

  scenario 'Dashboard progress show proposed actions' do
    action = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)
    expect(page).to have_content(action.title)

    find(:css, "#dashboard_action_#{action.id}_execute").click
    expect(page).not_to have_selector(:css, "#dashboard_action_#{action.id}_execute")
  end

  scenario 'Dashboard progress show available resources' do
    available = create(:dashboard_action, :resource, :active)

    requested = create(:dashboard_action, :resource, :admin_request, :active)
    executed_action = create(:dashboard_executed_action, action: requested, proposal: proposal, executed_at: Time.current)
    _task = create(:dashboard_administrator_task, :pending, source: executed_action)

    solved = create(:dashboard_action, :resource, :admin_request, :active)
    executed_solved_action = create(:dashboard_executed_action, action: solved, proposal: proposal, executed_at: Time.current)
    _solved_task = create(:dashboard_administrator_task, :done, source: executed_solved_action)

    unavailable = create(:dashboard_action, :resource, :active, required_supports: proposal.votes_for.size + 1_000)

    visit progress_proposal_dashboard_path(proposal)
    within 'div#available-resources-section' do
      expect(page).to have_content('Polls')
      expect(page).to have_content('E-mail')
      expect(page).to have_content('Poster')
      expect(page).to have_content(available.title)
      expect(page).to have_content(unavailable.title)
      expect(page).to have_content(requested.title)
      expect(page).to have_content(solved.title)

      within "div#dashboard_action_#{available.id}" do
        expect(page).to have_link('Request resource')
      end

      within "div#dashboard_action_#{requested.id}" do
        expect(page).to have_content('Resource already requested')
      end

      within "div#dashboard_action_#{unavailable.id}" do
        expect(page).to have_content('1.000 supports required')
      end

      within "div#dashboard_action_#{solved.id}" do
        expect(page).to have_link('See resource')
      end
    end
  end

  scenario 'Dashboard has a link to polls feature' do
    expect(page).to have_link('Polls')
  end

  scenario 'Dashboard has a link to e-mail feature' do
    expect(page).to have_link('E-mail')
  end

  scenario 'Dashboard has a link to poster feature' do
    expect(page).to have_link('Poster')
  end

  scenario 'Dashboard has a link to resources on main menu' do
    feature = create(:dashboard_action, :resource, :active)

    visit proposal_dashboard_path(proposal)
    expect(page).to have_link(feature.title)
  end

  scenario 'Request resource with admin request', js: true do
    feature = create(:dashboard_action, :resource, :active, :admin_request)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    click_button 'Request'
    expect(page).to have_content('The request for the administrator has been successfully sent.')
  end

  scenario 'Request already requested resource with admin request', js: true do
    feature = create(:dashboard_action, :resource, :active, :admin_request)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    create(:dashboard_executed_action, action: feature, proposal: proposal)

    click_button 'Request'
    expect(page).to have_content('Proposal has already been taken')
  end

  scenario 'Resource without admin request do not have a request link', js: true do
    feature = create(:dashboard_action, :resource, :active)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    expect(page).not_to have_button('Request')
  end

  scenario 'Dashboard has a link to dashboard community', js: true do
    expect(page).to have_link('Community')
    click_link 'Community'

    expect(page).to have_content('Participants')
    expect(page).to have_content('Debates')
    expect(page).to have_content('Comments')
    expect(page).to have_link('Access the community')
  end
end
