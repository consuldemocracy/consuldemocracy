require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:debate) { Debate.new }
  let(:comment) { create(:comment) }

  describe "Non-logged in user" do
    let(:user) { nil }

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should_not be_able_to(:edit, Debate) }
    it { should_not be_able_to(:vote, Debate) }
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

    it { should_not be_able_to(:comment_as_administrator, debate) }
    it { should_not be_able_to(:comment_as_moderator, debate) }

    describe 'flagging content' do
      it { should be_able_to(:flag, debate) }
      it { should be_able_to(:unflag, debate) }

      it { should be_able_to(:flag, comment) }
      it { should be_able_to(:unflag, comment) }

      describe "own comments" do
        let(:own_comment) { create(:comment, author: user) }

        it { should_not be_able_to(:flag, own_comment) }
        it { should_not be_able_to(:unflag, own_comment) }
      end

      describe "own debates" do
        let(:own_debate) { create(:debate, author: user) }

        it { should_not be_able_to(:flag, own_debate) }
        it { should_not be_able_to(:unflag, own_debate) }
      end
    end

    describe "other users" do
      let(:other_user) { create(:user) }
      it { should_not be_able_to(:show, other_user) }
      it { should_not be_able_to(:edit, other_user) }
    end

    describe "editing debates" do
      let(:own_debate) { create(:debate, author: user) }
      let(:own_debate_non_editable) { create(:debate, author: user) }

      before { allow(own_debate_non_editable).to receive(:editable?).and_return(false) }

      it { should be_able_to(:edit, own_debate) }
      it { should_not be_able_to(:edit, debate) } # Not his
      it { should_not be_able_to(:edit, own_debate_non_editable) }
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
      let(:own_comment)      { create(:comment, author: user) }
      let(:own_debate)       { create(:debate,  author: user) }
      let(:hidden_comment)   { create(:comment, :hidden) }
      let(:hidden_debate)    { create(:debate,  :hidden) }
      let(:ignored_comment)  { create(:comment, :with_ignored_flag) }
      let(:ignored_debate)   { create(:debate,  :with_ignored_flag) }

      it { should be_able_to(:hide, comment) }
      it { should be_able_to(:hide_in_moderation_screen, comment) }
      it { should_not be_able_to(:hide, hidden_comment) }
      it { should_not be_able_to(:hide, own_comment) }

      it { should be_able_to(:hide, debate) }
      it { should be_able_to(:hide_in_moderation_screen, debate) }
      it { should_not be_able_to(:hide, hidden_debate) }
      it { should_not be_able_to(:hide, own_debate) }

      it { should be_able_to(:ignore_flag, comment) }
      it { should_not be_able_to(:ignore_flag, hidden_comment) }
      it { should_not be_able_to(:ignore_flag, ignored_comment) }
      it { should_not be_able_to(:ignore_flag, own_comment) }

      it { should be_able_to(:ignore_flag, debate) }
      it { should_not be_able_to(:ignore_flag, hidden_debate) }
      it { should_not be_able_to(:ignore_flag, ignored_debate) }
      it { should_not be_able_to(:ignore_flag, own_debate) }

      it { should_not be_able_to(:hide, user) }
      it { should be_able_to(:hide, other_user) }

      it { should_not be_able_to(:restore, comment) }
      it { should_not be_able_to(:restore, debate) }
      it { should_not be_able_to(:restore, other_user) }

      it { should be_able_to(:comment_as_moderator, debate) }
      it { should_not be_able_to(:comment_as_administrator, debate) }
    end
  end

  describe "Administrator" do
    let(:user) { create(:user) }
    before { create(:administrator, user: user) }

    let(:other_user)  { create(:user) }
    let(:hidden_user) { create(:user, :hidden) }

    let(:hidden_debate)  { create(:debate, :hidden) }
    let(:hidden_comment) { create(:comment, :hidden) }
    let(:own_debate)     { create(:debate, author: user)}
    let(:own_comment)    { create(:comment, author: user)}

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should be_able_to(:vote, debate) }

    it { should_not be_able_to(:restore, comment) }
    it { should_not be_able_to(:restore, debate) }
    it { should_not be_able_to(:restore, other_user) }

    it { should be_able_to(:restore, hidden_comment) }
    it { should be_able_to(:restore, hidden_debate) }
    it { should be_able_to(:restore, hidden_user) }

    it { should_not be_able_to(:confirm_hide, comment) }
    it { should_not be_able_to(:confirm_hide, debate) }
    it { should_not be_able_to(:confirm_hide, other_user) }

    it { should be_able_to(:confirm_hide, hidden_comment) }
    it { should be_able_to(:confirm_hide, hidden_debate) }
    it { should be_able_to(:confirm_hide, hidden_user) }

    it { should be_able_to(:comment_as_administrator, debate) }
    it { should_not be_able_to(:comment_as_moderator, debate) }
  end
end
