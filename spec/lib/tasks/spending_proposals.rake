require 'rails_helper'

describe 'rake spending_proposals:migrate_winner_spending_proposals' do
  let(:forum) { create(:forum) }
  let(:spending_proposal1) { create(:spending_proposal, :feasible, :finished, compatible: true,
                                    price: 1000, ballot_lines_count: 30) }
  let(:spending_proposal2) { create(:spending_proposal, :feasible, :finished, compatible: true,
                                    price: 2000, ballot_lines_count: 20) }
  let(:spending_proposal3) { create(:spending_proposal, :feasible, compatible: false) }

  let(:budget) { create(:budget) }
  let(:investment1) { create(:budget_investment, budget: budget,
                             original_spending_proposal_id: spending_proposal1.id) }
  let(:investment2) { create(:budget_investment, budget: budget,
                             original_spending_proposal_id: spending_proposal2.id) }
  let(:investment3) { create(:budget_investment, budget: budget,
                             original_spending_proposal_id: spending_proposal3.id) }

  let :run_rake_task do
    Rake.application.invoke_task('spending_proposals:migrate_winner_spending_proposals')
  end

  it 'migrates winner Spending Proposals to their Budget::Investments' do
    create_list(:user, 30, :level_two, representative: forum)
    forum.ballot.spending_proposals << [spending_proposal1, spending_proposal2, spending_proposal3]

    expect(investment1.winner).to be(false)
    expect(investment2.winner).to be(false)
    expect(investment3.winner).to be(false)

    run_rake_task

    expect(investment1.reload.winner).to be(true)
    expect(investment2.reload.winner).to be(true)
    expect(investment3.reload.winner).to be(false)
  end
end
