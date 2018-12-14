module Budgets
  def expect_message_organizations_cannot_vote
    expect(page).to have_content 'Organization'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  def add_to_ballot(budget_investment)
    within("#budget_investment_#{budget_investment.id}") { click_link "Vote" }
    within("#sidebar") { expect(page).to have_content budget_investment.title }
    within("#budget_investment_#{budget_investment.id}") { expect(page).to have_content "Remove vote" }
  end
end
