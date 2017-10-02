require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Everyone" do
  subject(:ability) { Ability.new(user) }

  let(:user) { nil }
  let(:debate) { create(:debate) }
  let(:proposal) { create(:proposal) }

  let(:reviewing_ballot_budget) { create(:budget, phase: 'reviewing_ballots') }
  let(:finished_budget) { create(:budget, phase: 'finished') }

  it { should be_able_to(:index, Debate) }
  it { should be_able_to(:show, debate) }
  it { should_not be_able_to(:edit, Debate) }
  it { should_not be_able_to(:vote, Debate) }
  it { should_not be_able_to(:flag, Debate) }
  it { should_not be_able_to(:unflag, Debate) }

  it { should be_able_to(:index, Proposal) }
  it { should be_able_to(:show, proposal) }
  it { should_not be_able_to(:edit, Proposal) }
  it { should_not be_able_to(:vote, Proposal) }
  it { should_not be_able_to(:flag, Proposal) }
  it { should_not be_able_to(:unflag, Proposal) }

  it { should be_able_to(:show, Comment) }

  it { should be_able_to(:index, SpendingProposal) }
  it { should_not be_able_to(:create, SpendingProposal) }

  it { should be_able_to(:index, Budget) }

  it { should be_able_to(:read_results, finished_budget) }
  it { should_not be_able_to(:read_results, reviewing_ballot_budget) }
end
