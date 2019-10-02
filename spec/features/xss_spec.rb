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
end
