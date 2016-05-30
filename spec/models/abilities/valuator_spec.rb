require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Valuator" do
  subject(:ability) { Ability.new(user) }
  let(:user) { valuator.user }
  let(:valuator) { create(:valuator) }
  let(:non_assigned_investment) { create(:budget_investment) }

  let(:assigned_investment) { create(:budget_investment, budget: create(:budget, valuating: true)) }
  before(:each) { assigned_investment.valuators << valuator }

  let(:assigned_investment_not_valuating) { create(:budget_investment, budget: create(:budget, valuating: false)) }
  before(:each) { assigned_investment_not_valuating.valuators << valuator }

  it { should be_able_to(:read, SpendingProposal) }
  it { should be_able_to(:update, SpendingProposal) }
  it { should be_able_to(:valuate, SpendingProposal) }

  it { should_not be_able_to(:update, non_assigned_investment) }
  it { should_not be_able_to(:valuate, non_assigned_investment) }

  it { should be_able_to(:update, assigned_investment) }
  it { should be_able_to(:valuate, assigned_investment) }

  it { should_not be_able_to(:update, assigned_investment_not_valuating) }
  it { should_not be_able_to(:valuate, assigned_investment_not_valuating) }
end
