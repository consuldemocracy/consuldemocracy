require "rails_helper"
require "cancan/matchers"

describe Abilities::Valuator do
  subject(:ability) { Ability.new(user) }

  let(:user) { valuator.user }
  let(:group) { create(:valuator_group) }
  let(:valuator) { create(:valuator, valuator_group: group, can_edit_dossier: true, can_comment: true) }
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
  it { should be_able_to(:comment_valuation, assigned_investment) }

  it { should_not be_able_to(:valuate, non_assigned_investment) }
  it { should_not be_able_to(:valuate, finished_assigned_investment) }
  it { should_not be_able_to(:comment_valuation, finished_assigned_investment) }

  context "cannot edit dossier" do
    before { valuator.can_edit_dossier = false }

    it { should_not be_able_to(:valuate, assigned_investment) }
  end

  context "cannot comment" do
    before { valuator.can_comment = false }

    it { should_not be_able_to(:comment_valuation, assigned_investment) }
  end

  it { should_not be_able_to(:read, SDG::Target) }

  it { should_not be_able_to(:read, SDG::Manager) }
  it { should_not be_able_to(:create, SDG::Manager) }
  it { should_not be_able_to(:delete, SDG::Manager) }
end
