require "rails_helper"

describe "Cross-Site Scripting protection", :js do
  let(:attack_code) { "<script>document.body.remove()</script>" }

  scenario "valuators in admin investments index" do
    hacker = create(:user, username: attack_code)
    investment = create(:budget_investment, valuators: [create(:valuator, user: hacker)])

    login_as(create(:administrator).user)
    visit admin_budget_budget_investments_path(investment.budget)

    expect(page.text).not_to be_empty
  end

  scenario "document title" do
    process = create(:legislation_process)
    create(:document, documentable: process, title: attack_code)

    visit legislation_process_path(process)

    expect(page.text).not_to be_empty
  end

  scenario "hacked translations" do
    I18nContent.create(key: "admin.budget_investments.index.list.title", value: attack_code)

    login_as(create(:administrator).user)
    visit admin_budget_budget_investments_path(create(:budget_investment).budget)

    expect(page.text).not_to be_empty
  end

  scenario "accept terms label" do
    I18nContent.create(key: "form.accept_terms", value: attack_code)

    login_as(create(:user))
    visit new_debate_path

    expect(page.text).not_to be_empty
  end

  scenario "link to sign in" do
    I18nContent.create(key: "budgets.investments.index.sidebar.not_logged_in", value: attack_code)
    create(:budget, phase: "accepting")

    visit budgets_path

    expect(page.text).not_to be_empty
  end

  scenario "proposal actions in dashboard" do
    proposal = create(:proposal)

    create(:dashboard_action, description: attack_code)

    login_as(proposal.author)
    visit recommended_actions_proposal_dashboard_path(proposal)

    expect(page.text).not_to be_empty
  end

  scenario "annotation context" do
    annotation = create(:legislation_annotation)
    annotation.update_column(:context, attack_code)

    visit polymorphic_hierarchy_path(annotation)

    expect(page.text).not_to be_empty
  end

  scenario "valuation explanations" do
    investment = create(:budget_investment, price_explanation: attack_code)
    valuator = create(:valuator, investments: [investment])

    login_as(valuator.user)
    visit valuation_budget_budget_investment_path(investment.budget, investment)

    expect(page.text).not_to be_empty
  end

  scenario "markdown conversion" do
    process = create(:legislation_process, description: attack_code)

    visit legislation_process_path(process)

    expect(page.text).not_to be_empty
  end
end
