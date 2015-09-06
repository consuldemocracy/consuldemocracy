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

  describe "#comment_flags" do
    let(:user) { create(:user) }

    it "returns {} if no comment" do
      expect(user.comment_flags([])).to eq({})
    end

    it "returns a hash of flaggable_ids with 'true' if they were flagged by the user" do
      comment1 = create(:comment)
      comment2 = create(:comment)
      comment3 = create(:comment)
      Flag.flag(user, comment1)
      Flag.flag(user, comment3)

      flagged = user.comment_flags([comment1, comment2, comment3])

      expect(flagged[comment1.id]).to be
      expect(flagged[comment2.id]).to_not be
      expect(flagged[comment3.id]).to be
    end
  end

  subject { build(:user) }

  it "is valid" do
    expect(subject).to be_valid
  end

  describe "#terms" do
    it "is not valid without accepting the terms of service" do
      subject.terms_of_service = nil
      expect(subject).to_not be_valid
    end
  end

  describe "#name" do
    it "is the username when the user is not an organization" do
      expect(subject.name).to eq(subject.username)
    end
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

  describe 'OmniAuth' do
    describe '#email_provided?' do
      it "is false if the email matchs was temporarely assigned by the OmniAuth process" do
        subject.email = 'omniauth@participacion-ABCD-twitter.com'
        expect(subject.email_provided?).to eq(false)
      end

      it "is true if the email is not omniauth-like" do
        subject.email = 'manuelacarmena@example.com'
        expect(subject.email_provided?).to eq(true)
      end

      it "is true if the user's real email is pending to be confirmed" do
        subject.email = 'omniauth@participacion-ABCD-twitter.com'
        subject.unconfirmed_email = 'manuelacarmena@example.com'
        expect(subject.email_provided?).to eq(true)
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

  describe "verified_organization?" do
    it "is falsy when the user is not an organization" do
      expect(subject).to_not be_verified_organization
    end

    describe 'when it is an organization' do
      before(:each) { create(:organization, user: subject) }

      it "is false when the user is not a verified organization" do
        expect(subject).to_not be_verified_organization
      end

      it "is true when the user is a verified organization" do
        subject.organization.verify
        expect(subject).to be_verified_organization
      end
    end
  end

  describe "organization_attributes" do
    before(:each) { subject.organization_attributes = {name: 'org'} }

    it "triggers the creation of an associated organization" do
      expect(subject.organization).to be
      expect(subject.organization.name).to eq('org')
    end

    it "deactivates the validation of username, and activates the validation of organization" do
      subject.username = nil
      expect(subject).to be_valid

      subject.organization.name= nil
      expect(subject).to_not be_valid
    end
  end

  describe "official?" do
    it "is false when the user is not an official" do
      expect(subject.official_level).to eq(0)
      expect(subject.official?).to be false
    end

    it "is true when the user is an official" do
      subject.official_level = 3
      subject.save
      expect(subject.official?).to be true
    end
  end

  describe "add_official_position!" do
    it "is false when level not valid" do
      expect(subject.add_official_position!("Boss", 89)).to be false
    end

    it "updates official position fields" do
      expect(subject).not_to be_official
      subject.add_official_position!("Veterinarian", 2)

      expect(subject).to be_official
      expect(subject.official_position).to eq("Veterinarian")
      expect(subject.official_level).to eq(2)

      subject.add_official_position!("Brain surgeon", 3)
      expect(subject.official_position).to eq("Brain surgeon")
      expect(subject.official_level).to eq(3)
    end
  end

  describe "remove_official_position!" do
    it "updates official position fields" do
      subject.add_official_position!("Brain surgeon", 3)
      expect(subject).to be_official

      subject.remove_official_position!

      expect(subject).not_to be_official
      expect(subject.official_position).to be_nil
      expect(subject.official_level).to eq(0)
    end
  end

  describe "officials scope" do
    it "returns only users with official positions" do
      create(:user, official_position: "Mayor", official_level: 1)
      create(:user, official_position: "Director", official_level: 3)
      create(:user, official_position: "Math Teacher", official_level: 4)
      create(:user, official_position: "Manager", official_level: 5)
      2.times { create(:user) }

      officials = User.officials
      expect(officials.size).to eq(4)
      officials.each do |user|
        expect(user.official_level).to be > 0
        expect(user.official_position).to be_present
      end
    end
  end

  describe "self.search" do
    it "find users by email" do
      user1 = create(:user, email: "larry@madrid.es")
      create(:user, email: "bird@madrid.es")
      search = User.search("larry@madrid.es")
      expect(search.size).to eq(1)
      expect(search.first).to eq(user1)
    end

    it "find users by name" do
      user1 = create(:user, username: "Larry Bird")
      create(:user, username: "Robert Parish")
      search = User.search("larry")
      expect(search.size).to eq(1)
      expect(search.first).to eq(user1)
    end

    it "returns no results if no search term provided" do
      expect(User.search("    ").size).to eq(0)
    end
  end

  describe "verification levels" do
    it "residence_verified? is true only if residence_verified_at" do
      user = create(:user, residence_verified_at: Time.now)
      expect(user.residence_verified?).to eq(true)

      user = create(:user, residence_verified_at: nil)
      expect(user.residence_verified?).to eq(false)
    end

    it "sms_verified? is true only if confirmed_phone" do
      user = create(:user, confirmed_phone: "123456789")
      expect(user.sms_verified?).to eq(true)

      user = create(:user, confirmed_phone: nil)
      expect(user.sms_verified?).to eq(false)
    end

    it "level_two_verified? is true only if residence_verified_at and confirmed_phone" do
      user = create(:user, confirmed_phone: "123456789", residence_verified_at: Time.now)
      expect(user.level_two_verified?).to eq(true)

      user = create(:user, confirmed_phone: nil, residence_verified_at: Time.now)
      expect(user.level_two_verified?).to eq(false)

      user = create(:user, confirmed_phone: "123456789", residence_verified_at: nil)
      expect(user.level_two_verified?).to eq(false)
    end

    it "level_three_verified? is true only if verified_at" do
      user = create(:user, verified_at: Time.now)
      expect(user.level_three_verified?).to eq(true)

      user = create(:user, verified_at: nil)
      expect(user.level_three_verified?).to eq(false)
    end

    it "unverified? is true only if not level_three_verified and not level_two_verified" do
      user = create(:user, verified_at: nil, confirmed_phone: nil)
      expect(user.unverified?).to eq(true)

      user = create(:user, verified_at: Time.now, confirmed_phone: "123456789", residence_verified_at: Time.now)
      expect(user.unverified?).to eq(false)
    end
  end

  describe "cache" do
    let(:user) { create(:user) }

    it "should expire cache with becoming a moderator" do
      expect { create(:moderator, user: user) }
      .to change { user.updated_at}
    end

    it "should expire cache with becoming an admin" do
      expect { create(:administrator, user: user) }
      .to change { user.updated_at}
    end

    it "should expire cache with becoming a veridied organization" do
      create(:organization, user: user)
      expect { user.organization.verify }
      .to change { user.reload.updated_at}
    end

  end

end
