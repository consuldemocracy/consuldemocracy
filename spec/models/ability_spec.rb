require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:debate) { create(:debate) }
  let(:comment) { create(:comment) }
  let(:proposal) { create(:proposal) }

  let(:own_debate) { create(:debate, author: user) }
  let(:own_comment) { create(:comment, author: user) }
  let(:own_proposal) { create(:proposal, author: user) }

  let(:hidden_debate) { create(:debate, :hidden) }
  let(:hidden_comment) { create(:comment, :hidden) }
  let(:hidden_proposal) { create(:proposal, :hidden) }

  describe "Non-logged in user" do
    let(:user) { nil }

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
  end

  describe "Citizen" do
    let(:user) { create(:user) }

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
      it { should_not be_able_to(:show, other_user) }
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
      before{ user.update(residence_verified_at: Time.now, confirmed_phone: "1") }

      it { should be_able_to(:vote, Proposal) }
    end

    describe "when level 3 verified" do
      before{ user.update(verified_at: Time.now) }

      it { should be_able_to(:vote, Proposal) }
    end
  end

  describe "Organization" do
    let(:user) { create(:user) }
    before(:each) { create(:organization, user: user) }

    it { should be_able_to(:show, user) }
    it { should be_able_to(:edit, user) }

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should_not be_able_to(:vote, debate) }

    it { should be_able_to(:index, Proposal) }
    it { should be_able_to(:show, proposal) }
    it { should_not be_able_to(:vote, Proposal) }

    it { should be_able_to(:create, Comment) }
    it { should_not be_able_to(:vote, Comment) }
  end

  describe "Moderator" do
    let(:user) { create(:user) }
    before { create(:moderator, user: user) }
    let(:other_user) { create(:user) }


    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should be_able_to(:vote, debate) }

    it { should be_able_to(:index, Proposal) }
    it { should be_able_to(:show, proposal) }

    it { should be_able_to(:read, Organization) }

    describe "organizations" do
      let(:pending_organization)  { create(:organization) }
      let(:rejected_organization) { create(:organization, :rejected) }
      let(:verified_organization) { create(:organization, :verified) }

      it { should be_able_to(    :verify, pending_organization)  }
      it { should be_able_to(    :reject, pending_organization)  }

      it { should_not be_able_to(:verify, verified_organization) }
      it { should be_able_to(    :reject, verified_organization) }

      it { should_not be_able_to(:reject, rejected_organization) }
      it { should be_able_to(    :verify, rejected_organization) }
    end

    describe "hiding, reviewing and restoring" do
      let(:ignored_comment)  { create(:comment, :with_ignored_flag) }
      let(:ignored_debate)   { create(:debate,  :with_ignored_flag) }
      let(:ignored_proposal) { create(:proposal,:with_ignored_flag) }

      it { should be_able_to(:hide, comment) }
      it { should be_able_to(:hide_in_moderation_screen, comment) }
      it { should_not be_able_to(:hide, hidden_comment) }
      it { should_not be_able_to(:hide, own_comment) }

      it { should be_able_to(:hide, debate) }
      it { should be_able_to(:hide_in_moderation_screen, debate) }
      it { should_not be_able_to(:hide, hidden_debate) }
      it { should_not be_able_to(:hide, own_debate) }

      it { should be_able_to(:hide, proposal) }
      it { should be_able_to(:hide_in_moderation_screen, proposal) }
      it { should_not be_able_to(:hide, hidden_proposal) }
      it { should_not be_able_to(:hide, own_proposal) }

      it { should be_able_to(:ignore_flag, comment) }
      it { should_not be_able_to(:ignore_flag, hidden_comment) }
      it { should_not be_able_to(:ignore_flag, ignored_comment) }
      it { should_not be_able_to(:ignore_flag, own_comment) }

      it { should be_able_to(:ignore_flag, debate) }
      it { should_not be_able_to(:ignore_flag, hidden_debate) }
      it { should_not be_able_to(:ignore_flag, ignored_debate) }
      it { should_not be_able_to(:ignore_flag, own_debate) }

      it { should be_able_to(:ignore_flag, proposal) }
      it { should_not be_able_to(:ignore_flag, hidden_proposal) }
      it { should_not be_able_to(:ignore_flag, ignored_proposal) }
      it { should_not be_able_to(:ignore_flag, own_proposal) }

      it { should be_able_to(:moderate, proposal) }
      it { should_not be_able_to(:moderate, own_proposal) }

      it { should_not be_able_to(:hide, user) }
      it { should be_able_to(:hide, other_user) }

      it { should_not be_able_to(:block, user) }
      it { should be_able_to(:block, other_user) }

      it { should_not be_able_to(:restore, comment) }
      it { should_not be_able_to(:restore, debate) }
      it { should_not be_able_to(:restore, proposal) }
      it { should_not be_able_to(:restore, other_user) }

      it { should be_able_to(:comment_as_moderator, debate) }
      it { should be_able_to(:comment_as_moderator, proposal) }
      it { should_not be_able_to(:comment_as_administrator, debate) }
      it { should_not be_able_to(:comment_as_administrator, proposal) }
    end
  end

  describe "Administrator" do
    let(:user) { create(:user) }
    before { create(:administrator, user: user) }

    let(:other_user)  { create(:user) }
    let(:hidden_user) { create(:user, :hidden) }

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should be_able_to(:vote, debate) }

    it { should be_able_to(:index, Proposal) }
    it { should be_able_to(:show, proposal) }

    it { should_not be_able_to(:restore, comment) }
    it { should_not be_able_to(:restore, debate) }
    it { should_not be_able_to(:restore, proposal) }
    it { should_not be_able_to(:restore, other_user) }

    it { should be_able_to(:restore, hidden_comment) }
    it { should be_able_to(:restore, hidden_debate) }
    it { should be_able_to(:restore, hidden_proposal) }
    it { should be_able_to(:restore, hidden_user) }

    it { should_not be_able_to(:confirm_hide, comment) }
    it { should_not be_able_to(:confirm_hide, debate) }
    it { should_not be_able_to(:confirm_hide, proposal) }
    it { should_not be_able_to(:confirm_hide, other_user) }

    it { should be_able_to(:confirm_hide, hidden_comment) }
    it { should be_able_to(:confirm_hide, hidden_debate) }
    it { should be_able_to(:confirm_hide, hidden_proposal) }
    it { should be_able_to(:confirm_hide, hidden_user) }

    it { should be_able_to(:comment_as_administrator, debate) }
    it { should_not be_able_to(:comment_as_moderator, debate) }

    it { should be_able_to(:comment_as_administrator, proposal) }
    it { should_not be_able_to(:comment_as_moderator, proposal) }
  end
end
