require 'rails_helper'
require 'cancan/matchers'

describe "Abilities::Common" do
  subject(:ability) { Ability.new(user) }

  let(:user) { create(:user) }

  let(:debate) { create(:debate) }
  let(:comment) { create(:comment) }
  let(:proposal) { create(:proposal) }
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
  it { should_not be_able_to(:vote, SpendingProposal) }
  it { should_not be_able_to(:destroy, SpendingProposal) }

  it { should_not be_able_to(:show, Ballot) }

  it { should_not be_able_to(:comment_as_administrator, debate) }
  it { should_not be_able_to(:comment_as_moderator, debate) }
  it { should_not be_able_to(:comment_as_administrator, proposal) }
  it { should_not be_able_to(:comment_as_moderator, proposal) }

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
    let(:spending_proposal) { create(:spending_proposal) }
    let(:own_spending_proposal) { create(:spending_proposal, author: user) }
    before{ user.update(residence_verified_at: Time.now, confirmed_phone: "1") }

    it { should be_able_to(:vote, Proposal) }
    it { should be_able_to(:vote_featured, Proposal) }

    it { should be_able_to(:create, SpendingProposal) }
    it { should be_able_to(:vote, SpendingProposal) }

    it { should be_able_to(:create, BallotLine) }
    it { should be_able_to(:destroy, BallotLine) }

    it { should_not be_able_to(:destroy, spending_proposal) }
    it { should_not be_able_to(:destroy, own_spending_proposal) }

    it { should be_able_to(:show, Ballot) }
  end

  describe "when level 3 verified" do
    let(:spending_proposal) { create(:spending_proposal) }
    let(:own_spending_proposal) { create(:spending_proposal, author: user) }
    before{ user.update(verified_at: Time.now) }

    it { should be_able_to(:vote, Proposal) }
    it { should be_able_to(:vote_featured, Proposal) }

    it { should be_able_to(:create, SpendingProposal) }
    it { should be_able_to(:vote, SpendingProposal) }

    it { should be_able_to(:create, BallotLine) }
    it { should be_able_to(:destroy, BallotLine) }

    it { should_not be_able_to(:destroy, spending_proposal) }
    it { should_not be_able_to(:destroy, own_spending_proposal) }

    it { should be_able_to(:show, Ballot) }
  end

  describe "when forum" do
    let!(:forum) { create(:forum, user: user) }
    let(:spending_proposal) { create(:spending_proposal) }
    let(:own_spending_proposal) { create(:spending_proposal, author: user) }


    it { should_not be_able_to(:vote, Proposal) }
    it { should_not be_able_to(:vote_featured, Proposal) }

    it { should_not be_able_to(:create, SpendingProposal) }

    it { should be_able_to(:vote, SpendingProposal) }

    it { should be_able_to(:create, BallotLine) }
    it { should be_able_to(:destroy, BallotLine) }

    it { should_not be_able_to(:destroy, spending_proposal) }
    it { should_not be_able_to(:destroy, own_spending_proposal) }
  end

end
