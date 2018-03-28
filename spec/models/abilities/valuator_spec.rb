require 'rails_helper'
require 'cancan/matchers'

describe Abilities::Valuator do
  subject(:ability) { Ability.new(user) }

  let(:user) { valuator.user }
  let(:valuator) { create(:valuator) }
  let(:non_assigned_investment) { create(:budget_investment) }
  let(:assigned_investment) { create(:budget_investment, budget: create(:budget, phase: 'valuating')) }
  let(:finished_assigned_investment) { create(:budget_investment, budget: create(:budget, phase: 'finished')) }

  before do
    assigned_investment.valuators << valuator
    finished_assigned_investment.valuators << valuator
  end

  it { should be_able_to(:read, SpendingProposal) }
  it { should be_able_to(:update, SpendingProposal) }
  it { should be_able_to(:valuate, SpendingProposal) }

  it "cannot valuate an assigned investment with a finished valuation" do
    assigned_investment.update(valuation_finished: true)

    should_not be_able_to(:valuate, assigned_investment)
  end

  it { should_not be_able_to(:update, non_assigned_investment) }
  it { should_not be_able_to(:valuate, non_assigned_investment) }

  it { should be_able_to(:update, assigned_investment) }
  it { should be_able_to(:valuate, assigned_investment) }

  it { should_not be_able_to(:update, finished_assigned_investment) }
  it { should_not be_able_to(:valuate, finished_assigned_investment) }
end
