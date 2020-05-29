module Budgets
  def expect_message_organizations_cannot_vote
    expect(page).to have_content "Organization"
    expect(page).to have_selector(".in-favor a", visible: false)
  end

  def add_to_ballot(investment_title)
    within(".budget-investment", text: investment_title) do
      find(".add a").click
      expect(page).to have_content "Remove"
    end
  end
end
