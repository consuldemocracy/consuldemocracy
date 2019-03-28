module Budgets
  def expect_message_organizations_cannot_vote
    expect(page).to have_content "Organization"
    expect(page).to have_selector(".in-favor a", visible: false)
  end

  def add_to_ballot(budget_investment)
    within("#budget_investment_#{budget_investment.id}") do
      find(".add a").click
      expect(page).to have_content "Remove"
    end
  end

  def budget_invesment_for(spending_proposal, options={})
    attributes = {
      original_spending_proposal_id: spending_proposal.id,
      selected: true
    }.merge(options)

    create(:budget_investment, attributes)
  end
end
