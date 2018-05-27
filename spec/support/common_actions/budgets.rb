module Budgets
  # spec/features/budgets/ballots_spec.rb
  def expect_message_organizations_cannot_vote
    #expect(page).to have_content 'Organisations are not permitted to vote.'
    expect(page).to have_content 'Organization'
    expect(page).to have_selector('.in-favor a', visible: false)
  end

  # spec/features/budgets/ballots_spec.rb
  # spec/features/budgets/investments_spec.rb
  def add_to_ballot(budget_investment)
    within("#budget_investment_#{budget_investment.id}") do
      find('.add a').click
      expect(page).to have_content "Remove"
    end
  end
end
