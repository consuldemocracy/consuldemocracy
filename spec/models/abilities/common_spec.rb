require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Common" do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:user) }

  let(:debate) { create(:debate) }
  let(:comment) { create(:comment) }
  let(:proposal) { create(:proposal) }
  let(:accepting_budget) { create(:budget, phase: 'accepting') }
  let(:reviewing_budget) { create(:budget, phase: 'reviewing') }
  let(:selecting_budget) { create(:budget, phase: 'selecting') }
  let(:balloting_budget) { create(:budget, phase: 'balloting') }

  let(:investment_in_accepting_budget) { create(:budget_investment, budget: accepting_budget) }
  let(:investment_in_reviewing_budget) { create(:budget_investment, budget: reviewing_budget) }
  let(:investment_in_selecting_budget) { create(:budget_investment, budget: selecting_budget) }
  let(:investment_in_balloting_budget) { create(:budget_investment, budget: balloting_budget) }
  let(:own_investment_in_accepting_budget) { create(:budget_investment, budget: accepting_budget, author: user) }
  let(:own_investment_in_reviewing_budget) { create(:budget_investment, budget: reviewing_budget, author: user) }
  let(:own_investment_in_selecting_budget) { create(:budget_investment, budget: selecting_budget, author: user) }
  let(:own_investment_in_balloting_budget) { create(:budget_investment, budget: balloting_budget, author: user) }
  let(:ballot_in_accepting_budget) { create(:budget_ballot, budget: accepting_budget) }
  let(:ballot_in_selecting_budget) { create(:budget_ballot, budget: selecting_budget) }
  let(:ballot_in_balloting_budget) { create(:budget_ballot, budget: balloting_budget) }
  let(:own_debate) { create(:debate, author: user) }
  let(:own_comment) { create(:comment, author: user) }
  let(:own_proposal) { create(:proposal, author: user) }

  it { should be_able_to(:index, Debate) }
  it { should be_able_to(:show, debate) }
  it { should be_able_to(:vote, debate) }

  it { should be_able_to(:show, user) }
  it { should be_able_to(:edit, user) }

  it { should be_able_to(:create, Comment) }
  it { should be_able_to(:vote, Comment) }

  it { should be_able_to(:index, Proposal) }
  it { should be_able_to(:show, proposal) }
  it { should_not be_able_to(:vote, Proposal) }
  it { should_not be_able_to(:vote_featured, Proposal) }

  it { should be_able_to(:index, SpendingProposal) }
  it { should_not be_able_to(:create, SpendingProposal) }
  it { should_not be_able_to(:destroy, SpendingProposal) }

  it { should_not be_able_to(:comment_as_administrator, debate) }
  it { should_not be_able_to(:comment_as_moderator, debate) }
  it { should_not be_able_to(:comment_as_administrator, proposal) }
  it { should_not be_able_to(:comment_as_moderator, proposal) }

  it { should be_able_to(:new, DirectMessage) }
  it { should_not be_able_to(:create, DirectMessage) }
  it { should_not be_able_to(:show, DirectMessage) }

  describe 'flagging content' do
    it { should be_able_to(:flag, debate) }
    it { should be_able_to(:unflag, debate) }

    it { should be_able_to(:flag, comment) }
    it { should be_able_to(:unflag, comment) }

    it { should be_able_to(:flag, proposal) }
    it { should be_able_to(:unflag, proposal) }

    describe "own content" do
      it { should_not be_able_to(:flag, own_comment) }
      it { should_not be_able_to(:unflag, own_comment) }

      it { should_not be_able_to(:flag, own_debate) }
      it { should_not be_able_to(:unflag, own_debate) }

      it { should_not be_able_to(:flag, own_proposal) }
      it { should_not be_able_to(:unflag, own_proposal) }
    end
  end

  describe "other users" do
    let(:other_user) { create(:user) }
    it { should be_able_to(:show, other_user) }
    it { should_not be_able_to(:edit, other_user) }
  end

  describe "editing debates" do
    let(:own_debate_non_editable) { create(:debate, author: user) }
    before { allow(own_debate_non_editable).to receive(:editable?).and_return(false) }

    it { should be_able_to(:edit, own_debate) }
    it { should_not be_able_to(:edit, debate) } # Not his
    it { should_not be_able_to(:edit, own_debate_non_editable) }
  end

  describe "editing proposals" do
    let(:own_proposal_non_editable) { create(:proposal, author: user) }
    before { allow(own_proposal_non_editable).to receive(:editable?).and_return(false) }

    it { should be_able_to(:edit, own_proposal) }
    it { should_not be_able_to(:edit, proposal) } # Not his
    it { should_not be_able_to(:edit, own_proposal_non_editable) }
  end

  describe "when level 2 verified" do
    let(:own_spending_proposal) { create(:spending_proposal, author: user) }
    let(:own_direct_message) { create(:direct_message, sender: user) }
    before{ user.update(residence_verified_at: Time.current, confirmed_phone: "1") }

    it { should be_able_to(:vote, Proposal) }
    it { should be_able_to(:vote_featured, Proposal) }

    it { should be_able_to(:create, SpendingProposal) }
    it { should_not be_able_to(:destroy, create(:spending_proposal)) }
    it { should_not be_able_to(:destroy, own_spending_proposal) }

    it { should be_able_to(:create, investment_in_accepting_budget) }
    it { should_not be_able_to(:create, investment_in_selecting_budget) }
    it { should_not be_able_to(:create, investment_in_balloting_budget) }

    it { should_not be_able_to(:vote, investment_in_accepting_budget) }
    it { should be_able_to(:vote, investment_in_selecting_budget) }
    it { should_not be_able_to(:vote, investment_in_balloting_budget) }

    it { should_not be_able_to(:destroy, investment_in_accepting_budget) }
    it { should_not be_able_to(:destroy, investment_in_reviewing_budget) }
    it { should_not be_able_to(:destroy, investment_in_selecting_budget) }
    it { should_not be_able_to(:destroy, investment_in_balloting_budget) }

    it { should be_able_to(:destroy, own_investment_in_accepting_budget) }
    it { should be_able_to(:destroy, own_investment_in_reviewing_budget) }
    it { should_not be_able_to(:destroy, own_investment_in_selecting_budget) }
    it { should_not be_able_to(:destroy, investment_in_balloting_budget) }

    it { should_not be_able_to(:create, ballot_in_accepting_budget) }
    it { should_not be_able_to(:create, ballot_in_selecting_budget) }
    it { should be_able_to(:create, ballot_in_balloting_budget) }

    it { should be_able_to(:new, DirectMessage) }
    it { should be_able_to(:create, DirectMessage) }
    it { should be_able_to(:show, own_direct_message) }
    it { should_not be_able_to(:show, create(:direct_message)) }
  end

  describe "when level 3 verified" do
    let(:own_spending_proposal) { create(:spending_proposal, author: user) }
    let(:own_direct_message) { create(:direct_message, sender: user) }
    before{ user.update(verified_at: Time.current) }

    it { should be_able_to(:vote, Proposal) }
    it { should be_able_to(:vote_featured, Proposal) }

    it { should be_able_to(:create, SpendingProposal) }
    it { should_not be_able_to(:destroy, create(:spending_proposal)) }
    it { should_not be_able_to(:destroy, own_spending_proposal) }

    it { should be_able_to(:new, DirectMessage) }
    it { should be_able_to(:create, DirectMessage) }
    it { should be_able_to(:show, own_direct_message) }
    it { should_not be_able_to(:show, create(:direct_message)) }
  end
end
