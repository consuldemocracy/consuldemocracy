module Budgets
  def expect_message_organizations_cannot_vote
    expect(page).to have_content "Organization"
    expect(page).to have_selector(".in-favor a", obscured: true)
  end

  def hover_over_ballot
    scroll_to find("div.ballot"), align: :bottom
    find("div.ballot").hover
  end

  def add_to_ballot(investment_title)
    within(".budget-investment", text: investment_title) do
      find(".add a").click
      expect(page).to have_content "Remove"
    end
  end
end
