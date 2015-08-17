require 'rails_helper'

describe User do

  describe "#debate_votes" do
    let(:user) { create(:user) }

    it "returns {} if no debate" do
      expect(user.debate_votes([])).to eq({})
    end

    it "returns a hash of debates ids and votes" do
      debate1 = create(:debate)
      debate2 = create(:debate)
      debate3 = create(:debate)
      create(:vote, voter: user, votable: debate1, vote_flag: true)
      create(:vote, voter: user, votable: debate3, vote_flag: false)

      voted = user.debate_votes([debate1, debate2, debate3])

      expect(voted[debate1.id]).to eq(true)
      expect(voted[debate2.id]).to eq(nil)
      expect(voted[debate3.id]).to eq(false)
    end
  end

  subject { build(:user) }

  it "is valid" do
    expect(subject).to be_valid
  end

  describe 'preferences' do
    describe 'email_on_debate_comment' do
      it 'should be false by default' do
        expect(subject.email_on_debate_comment).to eq(false)
      end
    end

    describe 'email_on_comment_reply' do
      it 'should be false by default' do
        expect(subject.email_on_comment_reply).to eq(false)
      end
    end
  end

  describe 'use_nickname' do
    describe 'when true' do
      before { subject.use_nickname = true }

      it "activates the validation of nickname" do
        subject.nickname = nil
        expect(subject).to_not be_valid

        subject.nickname = "dredd"
        expect(subject).to be_valid
      end

      it "calculates the name using the nickname" do
        subject.nickname = "dredd"
        expect(subject.name).to eq("dredd")
      end
    end

    describe 'when false' do
      before { subject.use_nickname = false }

      it "activates the validation of first_name and last_name" do
        subject.first_name = nil
        subject.last_name = nil
        expect(subject).to_not be_valid

        subject.first_name = "Joseph"
        subject.last_name = "Dredd"
        expect(subject).to be_valid
      end

      it "calculates the name using first_name and last_name" do
        subject.first_name = "Joseph"
        subject.last_name = "Dredd"
        expect(subject.name).to eq("Joseph Dredd")
      end
    end
  end

  describe "administrator?" do
    it "is false when the user is not an admin" do
      expect(subject.administrator?).to be false
    end

    it "is true when the user is an admin" do
      subject.save
      create(:administrator, user: subject)
      expect(subject.administrator?).to be true
    end
  end

  describe "moderator?" do
    it "is false when the user is not a moderator" do
      expect(subject.moderator?).to be false
    end

    it "is true when the user is a moderator" do
      subject.save
      create(:moderator, user: subject)
      expect(subject.moderator?).to be true
    end
  end

  describe "organization?" do
    it "is false when the user is not an organization" do
      expect(subject.organization?).to be false
    end

    describe 'when it is an organization' do
      before(:each) { create(:organization, user: subject) }

      it "is true when the user is an organization" do
        expect(subject.organization?).to be true
      end

      it "calculates the name using the organization name" do
        expect(subject.name).to eq(subject.organization.name)
      end
    end
  end

  describe "organization_attributes" do
    before(:each) { subject.organization_attributes = {name: 'org'} }

    it "triggers the creation of an associated organization" do
      expect(subject.organization).to be
      expect(subject.organization.name).to eq('org')
    end

    it "deactivates the validation of first_name and last_name, and activates the validation of organization" do
      subject.first_name = nil
      subject.last_name = nil
      expect(subject).to be_valid

      subject.organization.name= nil
      expect(subject).to_not be_valid
    end
  end

end
