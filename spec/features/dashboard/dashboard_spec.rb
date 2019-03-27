require "rails_helper"

feature "Proposal's dashboard" do
  let!(:proposal) { create(:proposal, :draft) }

  before do
    login_as(proposal.author)
    visit proposal_dashboard_path(proposal)
  end

  scenario "Dashboard has a link to my proposal" do
    expect(page).to have_link("My proposal")
  end

  scenario "My proposal has a link to edit the proposal" do
    expect(page).to have_link("Edit proposal")
  end

  scenario "My proposal has a link to retire the proposal" do
    expect(page).to have_link("Retire proposal")
  end

  scenario "My proposal has a link to publish the proposal" do
    expect(page).to have_link("Publish proposal")
  end

  scenario "Publish link dissapears after proposal's publication" do
    click_link "Publish proposal"
    expect(page).not_to have_link("Publish proposal")
  end

  scenario "Dashboard progress shows current goal", js: true do
    goal = create(:dashboard_action, :resource, :active,
                                     required_supports: proposal.votes_for.size + 1_000)
    future_goal = create(:dashboard_action, :resource, :active,
                                            required_supports: proposal.votes_for.size + 2_000)

    visit progress_proposal_dashboard_path(proposal)

    within "div#goals-section" do
      expect(page).to have_content(goal.title)
      expect(page).not_to have_content(future_goal.title)

      find(:css, "#see_complete_course_link").click

      expect(page).to have_content(goal.title)
      expect(page).to have_content(future_goal.title)
    end
  end

  scenario "Dashboard progress show proposed actions" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)

    expect(page).to have_content(action.title)
  end

  scenario "Dashboard progress do not display from the fourth proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)
    action_5 = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)

    expect(page).not_to have_content(action_5.title)
  end

  scenario "Dashboard progress display link to new page for proposed actions when
            there are more than four proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)
    create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)

    expect(page).to have_link("Go to recommended actions")
  end

  scenario "Dashboard progress do not display link to new page for proposed actions
            when there are less than five proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)

    expect(page).not_to have_link("Check out recommended actions")
  end

  scenario "Dashboard progress display proposed_action pending on his section" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)

    within "#proposed_actions_pending" do
      expect(page).to have_content(action.title)
    end
  end

  scenario "Dashboard progress display contains no results text when there are not
            proposed_actions pending" do
    visit progress_proposal_dashboard_path(proposal)

    expect(page).to have_content("No recommended actions pending")
  end

  scenario "Dashboard progress display proposed_action done on his section" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)
    find(:css, "#dashboard_action_#{action.id}_execute").click

    within "#proposed_actions_done" do
      expect(page).to have_content(action.title)
    end
  end

  scenario "Dashboard progress can execute proposed action" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit progress_proposal_dashboard_path(proposal)
    expect(page).to have_content(action.title)

    find(:css, "#dashboard_action_#{action.id}_execute").click
    expect(page).not_to have_selector(:css, "#dashboard_action_#{action.id}_execute")
  end

  scenario "Dashboard progress dont show proposed actions with published_proposal: true" do
    action = create(:dashboard_action, :proposed_action, :active, published_proposal: true)

    visit progress_proposal_dashboard_path(proposal)

    expect(page).not_to have_content(action.title)
  end

  scenario "Dashboard progress show available resources for proposal draft" do
    available = create(:dashboard_action, :resource, :active)

    requested = create(:dashboard_action, :resource, :admin_request, :active)
    executed_action = create(:dashboard_executed_action, action: requested,
                              proposal: proposal, executed_at: Time.current)
    _task = create(:dashboard_administrator_task, :pending, source: executed_action)

    solved = create(:dashboard_action, :resource, :admin_request, :active)
    executed_solved_action = create(:dashboard_executed_action, action: solved,
                                     proposal: proposal, executed_at: Time.current)
    _solved_task = create(:dashboard_administrator_task, :done, source: executed_solved_action)

    unavailable = create(:dashboard_action, :resource, :active,
                          required_supports: proposal.votes_for.size + 1_000)

    visit progress_proposal_dashboard_path(proposal)
    within "div#available-resources-section" do
      expect(page).to have_content("Polls")
      expect(page).to have_content("E-mail")
      expect(page).to have_content("Poster")
      expect(page).to have_content(available.title)
      expect(page).to have_content(unavailable.title)
      expect(page).to have_content(requested.title)
      expect(page).to have_content(solved.title)

      within "div#dashboard_action_#{available.id}" do
        expect(page).to have_link("Request resource")
      end

      within "div#dashboard_action_#{requested.id}" do
        expect(page).to have_content("Resource already requested")
      end

      within "div#dashboard_action_#{unavailable.id}" do
        expect(page).to have_content("1.000 supports required")
      end

      within "div#dashboard_action_#{solved.id}" do
        expect(page).to have_link("See resource")
      end
    end
  end

  scenario "Dashboard progress show available resources for published proposal" do
    proposal.update(published_at: Date.today)
    available = create(:dashboard_action, :resource, :active)

    requested = create(:dashboard_action, :resource, :admin_request, :active)
    executed_action = create(:dashboard_executed_action, action: requested,
                              proposal: proposal, executed_at: Time.current)
    _task = create(:dashboard_administrator_task, :pending, source: executed_action)

    solved = create(:dashboard_action, :resource, :admin_request, :active)
    executed_solved_action = create(:dashboard_executed_action, action: solved,
                                     proposal: proposal, executed_at: Time.current)
    _solved_task = create(:dashboard_administrator_task, :done, source: executed_solved_action)

    unavailable = create(:dashboard_action, :resource, :active,
                          required_supports: proposal.votes_for.size + 1_000)

    visit progress_proposal_dashboard_path(proposal)
    within "div#available-resources-section" do
      expect(page).to have_content("Polls")
      expect(page).to have_content("E-mail")
      expect(page).to have_content("Poster")
      expect(page).to have_content(available.title)
      expect(page).to have_content(unavailable.title)
      expect(page).to have_content(requested.title)
      expect(page).to have_content(solved.title)

      within "div#dashboard_action_#{available.id}" do
        expect(page).to have_link("Request resource")
      end

      within "div#dashboard_action_#{requested.id}" do
        expect(page).to have_content("Resource already requested")
      end

      within "div#dashboard_action_#{unavailable.id}" do
        expect(page).to have_content("1.000 supports required")
      end

      within "div#dashboard_action_#{solved.id}" do
        expect(page).to have_link("See resource")
      end
    end
  end

  scenario "Dashboard progress dont show resources with published_proposal: true" do
    available = create(:dashboard_action, :resource, :active, published_proposal: true)
    unavailable = create(:dashboard_action, :resource, :active,
                          required_supports: proposal.votes_for.size + 1_000,
                          published_proposal: true)

    visit progress_proposal_dashboard_path(proposal)

    within "div#available-resources-section" do
      expect(page).to have_content("Polls")
      expect(page).to have_content("E-mail")
      expect(page).to have_content("Poster")
      expect(page).not_to have_content(available.title)
      expect(page).not_to have_content(unavailable.title)
    end
  end

  scenario "Dashboard has a link to polls feature" do
    expect(page).to have_link("Polls")
  end

  scenario "Dashboard has a link to e-mail feature" do
    expect(page).to have_link("E-mail")
  end

  scenario "Dashboard has a link to poster feature" do
    expect(page).to have_link("Poster")
  end

  scenario "Dashboard has a link to resources on main menu" do
    feature = create(:dashboard_action, :resource, :active)

    visit proposal_dashboard_path(proposal)
    expect(page).to have_link(feature.title)
  end

  scenario "Request resource with admin request", js: true do
    feature = create(:dashboard_action, :resource, :active, :admin_request)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    click_button "Request"
    expect(page).to have_content("The request for the administrator has been successfully sent.")
  end

  scenario "Request already requested resource with admin request", js: true do
    feature = create(:dashboard_action, :resource, :active, :admin_request)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    create(:dashboard_executed_action, action: feature, proposal: proposal)

    click_button "Request"
    expect(page).to have_content("Proposal has already been taken")
  end

  scenario "Resource without admin request do not have a request link", js: true do
    feature = create(:dashboard_action, :resource, :active)

    visit proposal_dashboard_path(proposal)
    click_link(feature.title)

    expect(page).not_to have_button("Request")
  end

  scenario "Dashboard has a link to dashboard community", js: true do
    expect(page).to have_link("Community")
    click_link "Community"

    expect(page).to have_content("Participants")
    expect(page).to have_content("Debates")
    expect(page).to have_content("Comments")
    expect(page).to have_link("Access the community")
  end

  scenario "Dashboard has a link to recommended_actions", js: true do
    expect(page).to have_link("Recommended actions")
    click_link "Recommended actions"

    expect(page).to have_content("Recommended actions")
    expect(page).to have_content("Pending")
    expect(page).to have_content("Done")
  end

  scenario "On recommended actions section display from the fourth proposed actions
            when click see_proposed_actions_link", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)
    action_5 = create(:dashboard_action, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)
    find(:css, "#see_proposed_actions_link_pending").click

    expect(page).to have_content(action_5.title)
  end

  scenario "On recommended actions section display four proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)
    action_5 = create(:dashboard_action, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)

    expect(page).not_to have_content(action_5.title)
  end

  scenario "On recommended actions section display link for toggle when there are
            more than four proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)
    create(:dashboard_action, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)

    expect(page).to have_content("Check out recommended actions")
  end

  scenario "On recommended actions section do not display link for toggle when
            there are less than five proposed actions", js: true do
    create_list(:dashboard_action, 4, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)

    expect(page).not_to have_link("Check out recommended actions")
  end

  scenario "On recommended actions section display proposed_action pending on his section" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)

    within "#proposed_actions_pending" do
      expect(page).to have_content(action.title)
    end
  end

  scenario "No recommended actions pending" do
    visit recommended_actions_proposal_dashboard_path(proposal.to_param)

    expect(page).to have_content("No recommended actions pending")
  end

  scenario "On recommended actions section display proposed_action done on his section" do
    action = create(:dashboard_action, :proposed_action, :active)

    visit recommended_actions_proposal_dashboard_path(proposal.to_param)
    find(:css, "#dashboard_action_#{action.id}_execute").click

    within "#proposed_actions_done" do
      expect(page).to have_content(action.title)
    end
  end

  scenario "No recommended actions done" do
    visit progress_proposal_dashboard_path(proposal)

    expect(page).to have_content("No recommended actions done")
  end

  describe "detect_new_actions_after_last_login" do

    before do
      proposal.author.update(last_sign_in_at: Date.yesterday)
    end

    scenario "Display tag 'new' on resouce when it is new for author since last login" do
      resource = create(:dashboard_action, :resource, :active, day_offset: 0,
                                                               published_proposal: false)

      visit progress_proposal_dashboard_path(proposal)

      within "#dashboard_action_#{resource.id}" do
        expect(page).to have_content("New")
      end
    end

    scenario "Not display tag 'new' on resouce when there is not new resources since last login" do
      resource = create(:dashboard_action, :resource, :active, day_offset: 0,
                                                               published_proposal: false)
      proposal.author.update(last_sign_in_at: Date.today)

      visit progress_proposal_dashboard_path(proposal)

      within "#dashboard_action_#{resource.id}" do
        expect(page).not_to have_content("New")
      end
    end

    scenario "Display tag 'new' on proposed_action when it is new for author since last login" do
      proposed_action = create(:dashboard_action, :proposed_action, :active, day_offset: 0,
                                                                     published_proposal: false)

      visit progress_proposal_dashboard_path(proposal)

      within "#dashboard_action_#{proposed_action.id}" do
        expect(page).to have_content("New")
      end
    end

    scenario "Not display tag 'new' on proposed_action when there is not new since last login" do
      proposed_action = create(:dashboard_action, :proposed_action, :active, day_offset: 0,
                                                                     published_proposal: false)
      proposal.author.update(last_sign_in_at: Date.today)

      visit progress_proposal_dashboard_path(proposal)

      within "#dashboard_action_#{proposed_action.id}" do
        expect(page).not_to have_content("New")
      end
    end

    scenario "Display tag 'new' on sidebar menu when there is a new resouce since last login" do
      create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: false)

      visit progress_proposal_dashboard_path(proposal)

      within "#side_menu" do
        expect(page).to have_content("New")
      end
    end

    scenario "Not display tag 'new' on sidebar when there is not a new resouce since last login" do
      create(:dashboard_action, :resource, :active, day_offset: 0, published_proposal: false)
      proposal.author.update(last_sign_in_at: Date.today)

      visit progress_proposal_dashboard_path(proposal)

      within "#side_menu" do
        expect(page).not_to have_content("New")
      end
    end

  end
end
