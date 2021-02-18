require "rails_helper"

describe "Cross-Site Scripting protection", :js do
  let(:attack_code) { "<script>document.body.remove()</script>" }

  scenario "valuators in admin investments index", :admin do
    hacker = create(:user, username: attack_code)
    investment = create(:budget_investment, valuators: [create(:valuator, user: hacker)])

    visit admin_budget_budget_investments_path(investment.budget)

    expect(page.text).not_to be_empty
  end

  scenario "edit banner", :admin do
    banner = create(:banner, title: attack_code)

    visit edit_admin_banner_path(banner)

    title_id = find_field("Title")[:id]
    execute_script "document.getElementById('#{title_id}').dispatchEvent(new Event('change'))"

    expect(page.text).not_to be_empty
  end

  scenario "banner URL", :admin do
    banner = create(:banner, title: "Banned!", target_url: "javascript:document.body.remove()")

    visit edit_admin_banner_path(banner)
    find(:css, "a", text: "Banned!").click

    expect(page.text).not_to be_empty
  end

  scenario "document title" do
    process = create(:legislation_process)
    create(:document, documentable: process, title: attack_code)

    visit legislation_process_path(process)

    expect(page.text).not_to be_empty
  end

  scenario "hacked translations", :admin do
    I18nContent.create!(key: "admin.budget_investments.index.list.title", value: attack_code)

    visit admin_budget_budget_investments_path(create(:budget_investment).budget)

    expect(page.text).not_to be_empty
  end

  scenario "accept terms label" do
    I18nContent.create!(key: "form.accept_terms", value: attack_code)

    login_as(create(:user))
    visit new_debate_path

    expect(page.text).not_to be_empty
  end

  scenario "link to sign in" do
    I18nContent.create!(key: "budgets.investments.index.sidebar.not_logged_in", value: attack_code)
    create(:budget, phase: "accepting")

    visit budgets_path

    expect(page.text).not_to be_empty
  end

  scenario "languages in use", :admin do
    I18nContent.create!(key: "shared.translations.languages_in_use", value: attack_code)

    visit edit_admin_budget_path(create(:budget))
    click_link "Remove language"

    expect(page.text).not_to be_empty
  end

  scenario "SDG identifier", :admin do
    Setting["feature.sdg"] = true
    Setting["sdg.process.proposals"] = true
    I18nContent.create!(key: "sdg.related_list_selector.goal_identifier", value: attack_code)

    visit sdg_management_edit_proposal_path(create(:proposal, sdg_goals: [SDG::Goal[1]]))

    expect(page.text).not_to be_empty
  end

  scenario "proposal actions in dashboard" do
    proposal = create(:proposal)

    create(:dashboard_action, description: attack_code)

    login_as(proposal.author)
    visit recommended_actions_proposal_dashboard_path(proposal)

    expect(page.text).not_to be_empty
  end

  scenario "new request for proposal action in dashboard" do
    proposal = create(:proposal)
    action = create(:dashboard_action, description: attack_code)

    login_as(proposal.author)
    visit new_request_proposal_dashboard_action_path(proposal, action)

    expect(page.text).not_to be_empty
  end

  scenario "poll description setting in dashboard" do
    Setting["proposals.poll_description"] = attack_code
    proposal = create(:proposal)

    login_as(proposal.author)
    visit proposal_dashboard_polls_path(proposal)

    expect(page.text).not_to be_empty
  end

  scenario "annotation context" do
    annotation = create(:legislation_annotation)
    annotation.update_column(:context, attack_code)

    visit polymorphic_path(annotation)

    expect(page.text).not_to be_empty
  end

  scenario "valuation explanations" do
    investment = create(:budget_investment, price_explanation: attack_code)
    valuator = create(:valuator, investments: [investment])

    login_as(valuator.user)
    visit valuation_budget_budget_investment_path(investment.budget, investment)

    expect(page.text).not_to be_empty
  end

  scenario "proposal description" do
    proposal = create(:proposal, description: attack_code)

    visit proposal_path(proposal)

    expect(page.text).not_to be_empty
  end

  scenario "investment description" do
    investment = create(:budget_investment, description: attack_code)

    visit budget_investment_path(investment.budget, investment)

    expect(page.text).not_to be_empty
  end

  scenario "budget phase description" do
    budget = create(:budget)
    budget.current_phase.update!(description: attack_code)

    visit budget_path(budget)

    expect(page.text).not_to be_empty
  end

  scenario "markdown conversion" do
    process = create(:legislation_process, description: attack_code)

    visit legislation_process_path(process)

    expect(page.text).not_to be_empty
  end

  scenario "legislation version body filters script tags but not header IDs nor tags like images" do
    markdown = "# Title 1\n<a href='https://domain.com/url'>link</a><img src='/image.png'>"
    version = create(:legislation_draft_version, :published, body: "#{markdown}#{attack_code}")

    visit legislation_process_draft_version_path(version.process, version)

    expect(page.text).not_to be_empty
    expect(page).to have_css "h1#title-1", text: "Title 1"
    expect(page).to have_link "link", href: "https://domain.com/url"
    expect(page).to have_css('img[src="/image.png"')
  end
end
