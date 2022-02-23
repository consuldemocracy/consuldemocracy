module Budgets
  def expect_message_organizations_cannot_vote
    expect(page).to have_content "Organization"
    expect(page).to have_button "Vote", disabled: true, obscured: true
  end

  def hover_over_ballot
    scroll_to find("div.ballot"), align: :bottom
    first("div.ballot p").hover
  end

  def add_to_ballot(investment_title)
    within(".budget-investment", text: investment_title) do
      click_button "Vote"
      expect(page).to have_content "Remove"
    end
  end
end
