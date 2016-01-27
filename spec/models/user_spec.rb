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
    describe 'email_on_comment' do
      it 'should be false by default' do
        expect(subject.email_on_comment).to eq(false)
      end
    end

    describe 'email_on_comment_reply' do
      it 'should be false by default' do
        expect(subject.email_on_comment_reply).to eq(false)
      end
    end

    describe 'subscription_to_website_newsletter' do
      it 'should be false by default' do
        expect(subject.newsletter).to eq(false)
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
    before(:each) { subject.organization_attributes = {name: 'org', responsible_name: 'julia'} }

    it "triggers the creation of an associated organization" do
      expect(subject.organization).to be
      expect(subject.organization.name).to eq('org')
      expect(subject.organization.responsible_name).to eq('julia')
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

  describe "has_official_email" do
    it "checks if the mail address has the officials domain" do
      # We will use empleados.madrid.es as the officials' domain
      # Subdomains are also accepted

      Setting['email_domain_for_officials'] = 'officials.madrid.es'
      user1 = create(:user, email: "john@officials.madrid.es", confirmed_at: Time.now)
      user2 = create(:user, email: "john@yes.officials.madrid.es", confirmed_at: Time.now)
      user3 = create(:user, email: "john@unofficials.madrid.es", confirmed_at: Time.now)
      user4 = create(:user, email: "john@example.org", confirmed_at: Time.now)

      expect(user1.has_official_email?).to eq(true)
      expect(user2.has_official_email?).to eq(true)
      expect(user3.has_official_email?).to eq(false)
      expect(user4.has_official_email?).to eq(false)

      # We reset the officials' domain setting
      Setting.find_by(key: 'email_domain_for_officials').update(value: '')
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

  describe "verification" do
    it_behaves_like "verifiable"
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

  describe "document_number" do
    it "should upcase document number" do
      user = User.new({document_number: "x1234567z"})
      user.valid?
      expect(user.document_number).to eq("X1234567Z")
    end

    it "should remove all characters except numbers and letters" do
      user = User.new({document_number: " 12.345.678 - B"})
      user.valid?
      expect(user.document_number).to eq("12345678B")
    end

  end

  describe "#erase" do
    it "anonymizes a user and marks him as hidden" do
      user = create(:user,
                     username: "manolo",
                     unconfirmed_email: "a@a.com",
                     document_number: "1234",
                     phone_number: "5678",
                     encrypted_password: "foobar",
                     confirmation_token: "token1",
                     reset_password_token: "token2",
                     email_verification_token: "token3")
      user.erase('a test')
      user.reload

      expect(user.erase_reason).to eq('a test')
      expect(user.erased_at).to be

      expect(user.username).to be_nil

      expect(user.email).to be_nil
      expect(user.unconfirmed_email).to be_nil
      expect(user.document_number).to be_nil
      expect(user.phone_number).to be_nil

      expect(user.encrypted_password).to be_empty

      expect(user.confirmation_token).to be_nil
      expect(user.reset_password_token).to be_nil
      expect(user.email_verification_token).to be_nil
    end
  end

end
