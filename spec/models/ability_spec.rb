require 'rails_helper'
require 'cancan/matchers'

describe Ability do
  subject(:ability) { Ability.new(user) }
  let(:debate) { Debate.new }

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

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should be_able_to(:vote, debate) }

    it { should be_able_to(:read, Organization) }

    describe "organizations" do
      let(:pending_organization)  { create(:organization) }
      let(:rejected_organization) { create(:rejected_organization) }
      let(:verified_organization) { create(:verified_organization) }

      it { should be_able_to(    :verify, pending_organization)  }
      it { should be_able_to(    :reject, pending_organization)  }

      it { should_not be_able_to(:verify, verified_organization) }
      it { should be_able_to(    :reject, verified_organization) }

      it { should_not be_able_to(:reject, rejected_organization) }
      it { should be_able_to(    :verify, rejected_organization) }
    end
  end

  describe "Administrator" do
    let(:user) { create(:user) }
    before { create(:administrator, user: user) }

    it { should be_able_to(:index, Debate) }
    it { should be_able_to(:show, debate) }
    it { should be_able_to(:vote, debate) }

  end
end
