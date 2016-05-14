require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Valuator" do
  subject(:ability) { Ability.new(user) }
  let(:user) { valuator.user }
  let(:valuator) { create(:valuator) }

  before(:each) do
    Setting['feature.spending_proposal_features.valuation_allowed'] = true
  end

  it { should be_able_to(:read, SpendingProposal) }
  it { should be_able_to(:update, SpendingProposal) }
  it { should be_able_to(:valuate, SpendingProposal) }
end
