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

  scenario "proposal actions in dashboard" do
    proposal = create(:proposal)

    create(:dashboard_action, description: attack_code)

    login_as(proposal.author)
    visit recommended_actions_proposal_dashboard_path(proposal)

    expect(page.text).not_to be_empty
  end
end
