require "rails_helper"
require "cancan/matchers"

describe Abilities::Valuator do
  subject(:ability) { Ability.new(user) }

  let(:user) { valuator.user }
  let(:group) { create(:valuator_group) }
  let(:valuator) { create(:valuator, valuator_group: group) }
  let(:non_assigned_investment) { create(:budget_investment) }
  let(:assigned_investment) { create(:budget_investment, budget: create(:budget, :valuating), valuators: [valuator]) }
  let(:group_assigned_investment) { create(:budget_investment, budget: create(:budget, :valuating), valuator_groups: [group]) }
  let(:finished_assigned_investment) { create(:budget_investment, budget: create(:budget, :finished), valuators: [valuator]) }

  it "cannot valuate an assigned investment with a finished valuation" do
    assigned_investment.update!(valuation_finished: true)

    should_not be_able_to(:valuate, assigned_investment)
  end

  it { should_not be_able_to(:update, assigned_investment) }

  it { should be_able_to(:valuate, assigned_investment) }
  it { should be_able_to(:valuate, group_assigned_investment) }

  it { should_not be_able_to(:valuate, non_assigned_investment) }
  it { should_not be_able_to(:valuate, finished_assigned_investment) }

  it "can update dossier information if not set can_edit_dossier attribute" do
    should be_able_to(:edit_dossier, assigned_investment)
    allow(valuator).to receive(:can_edit_dossier?).and_return(false)
    ability = Ability.new(user)
    expect(ability.can?(:edit_dossier, assigned_investment)).to be_falsey
  end

  it "cannot create valuation comments if not set not can_comment attribute" do
    should be_able_to(:comment_valuation, assigned_investment)
    allow(valuator).to receive(:can_comment?).and_return(false)
    ability = Ability.new(user)
    expect(ability.can?(:comment_valuation, assigned_investment)).to be_falsey
  end
end
