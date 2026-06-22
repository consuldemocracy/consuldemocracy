require "rails_helper"

describe "Polls" do
  let!(:proposal) { create(:proposal, :draft) }

  before { login_as(proposal.author) }

  scenario "Has a link to polls feature" do
    visit proposal_dashboard_path(proposal)

    expect(page).to have_link("Polls")
  end

  scenario "Create a poll" do
    visit proposal_dashboard_path(proposal)
    click_link "Polls"
    click_link "Create poll"

    start_date = 1.week.from_now
    end_date = 2.weeks.from_now

    fill_in "poll_name", with: "Proposal poll"
    find_field("poll_starts_at").set(start_date.to_date)
    find_field("poll_ends_at").set(end_date.to_date)
    fill_in "poll_description", with: "Proposal's poll description. This poll..."

    expect(page).not_to have_css("#poll_results_enabled")
    expect(page).not_to have_css("#poll_stats_enabled")

    click_link "Add question"

    fill_in "Question", with: "First question"

    click_link "Add answer"

    fill_in "Answer", with: "First answer"

    click_button "Create poll"
    expect(page).to have_content "Poll created successfully"
    expect(page).to have_content "Proposal poll"
    expect(page).to have_content I18n.l(start_date.to_date)
  end

  scenario "Create a poll redirects back to form when invalid data" do
    visit proposal_dashboard_path(proposal)
    click_link "Polls"
    click_link "Create poll"

    click_button "Create poll"

    expect(page).to have_content("New poll")
  end

  scenario "Edit poll is allowed for upcoming polls" do
    poll = create(:poll, related: proposal, starts_at: 1.week.from_now)

    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content("Edit survey")

      click_link "Edit survey"
    end

    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"
  end

  scenario "Edit poll redirects back when invalid data" do
    poll = create(:poll, related: proposal, starts_at: 1.week.from_now)

    visit proposal_dashboard_polls_path(proposal)

    within "div#poll_#{poll.id}" do
      expect(page).to have_content("Edit survey")

      click_link "Edit survey"
    end

    fill_in "poll_name", with: ""

    click_button "Update poll"

    expect(page).to have_content("Edit poll")
  end

  scenario "Edit poll should allow to remove questions" do
    poll = create(:poll, related: proposal, starts_at: 1.week.from_now)
    create(:poll_question, poll: poll)
    create(:poll_question, poll: poll)
    visit proposal_dashboard_polls_path(proposal)
    within "div#poll_#{poll.id}" do
      click_link "Edit survey"
    end

    within ".js-questions" do
      expect(page).to have_css ".nested-fields", count: 2
      within first(".nested-fields") do
        click_link class: "delete"
      end
      expect(page).to have_css ".nested-fields", count: 1
    end

    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"

    visit edit_proposal_dashboard_poll_path(proposal, poll)

    expect(page).to have_css ".nested-fields", count: 1
  end

  scenario "Edit poll allows users to remove options" do
    poll = create(:poll, related: proposal, starts_at: 1.week.from_now)
    create(:poll_question, :yes_no, poll: poll)
    visit proposal_dashboard_polls_path(proposal)
    within "div#poll_#{poll.id}" do
      click_link "Edit survey"
    end

    within ".js-questions .js-options" do
      expect(page).to have_css ".nested-fields", count: 2
      within first(".nested-fields") do
        click_link class: "delete"
      end
      expect(page).to have_css ".nested-fields", count: 1
    end

    click_button "Update poll"

    expect(page).to have_content "Poll updated successfully"

    visit edit_proposal_dashboard_poll_path(proposal, poll)

    within ".js-questions .js-options" do
      expect(page).to have_css ".nested-fields", count: 1
    end
  end

  scenario "Can destroy poll without responses" do
    poll = create(:poll, related: proposal)

    visit proposal_dashboard_polls_path(proposal)

    within("#poll_#{poll.id}") do
      accept_confirm { click_button "Delete survey" }
    end

    expect(page).to have_content("Survey deleted successfully")
    expect(page).not_to have_content(poll.name)
  end

  scenario "Can't destroy poll with responses" do
    poll = create(:poll, related: proposal)
    create(:poll_question, poll: poll)
    create(:poll_voter, poll: poll)

    visit proposal_dashboard_polls_path(proposal)

    within("#poll_#{poll.id}") do
      accept_confirm { click_button "Delete survey" }
    end

    expect(page).to have_content("You cannot destroy a survey that has responses")
    expect(page).to have_content(poll.name)
  end

  scenario "View results redirects to results in public zone" do
    poll = create(:poll, :expired, related: proposal)

    visit proposal_dashboard_polls_path(proposal)

    click_link "View results"

    expect(page).to have_current_path(results_proposal_poll_path(proposal, poll))
  end

  scenario "Enable and disable results" do
    create(:poll, related: proposal)

    visit proposal_dashboard_polls_path(proposal)
    check "Show results"

    expect(find_field("Show results")).to be_checked

    uncheck "Show results"

    expect(find_field("Show results")).not_to be_checked
  end
end
