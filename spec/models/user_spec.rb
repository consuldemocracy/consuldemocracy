require "rails_helper"
require 'devise_two_factor/spec_helpers'

describe User do
  describe "#headings_voted_within_group" do
    it "returns the headings voted by a user" do
      budget = create(:budget)
      group = create(:budget_group, budget: budget)

      new_york = create(:budget_heading, group: group, name: "New york")
      san_francisco = create(:budget_heading, group: group, name: "San Franciso")
      wyoming = create(:budget_heading, group: group, name: "Wyoming")
      another_heading = create(:budget_heading, group: group)

      new_york_investment = create(:budget_investment, heading: new_york)
      san_franciso_investment = create(:budget_investment, heading: san_francisco)
      wyoming_investment = create(:budget_investment, heading: wyoming)

      user1 = create(:user, votables: [wyoming_investment, san_franciso_investment, new_york_investment])
      user2 = create(:user)

      expect(user1.headings_voted_within_group(group)).to match_array [new_york, san_francisco, wyoming]
      expect(user1.headings_voted_within_group(group)).not_to include(another_heading)

      expect(user2.headings_voted_within_group(group)).to be_empty
    end

    it "returns headings with multiple translations only once" do
      group = create(:budget_group)
      heading = create(:budget_heading, group: group, name_en: "English", name_es: "Spanish")
      user = create(:user, votables: [create(:budget_investment, heading: heading)])

      expect(user.headings_voted_within_group(group).count).to eq 1
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
      expect(flagged[comment2.id]).not_to be
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
      expect(subject).not_to be_valid
    end
  end

  describe "#name" do
    it "is the username when the user is not an organization" do
      expect(subject.name).to eq(subject.username)
    end
  end

  describe "#age" do
    it "is the rounded integer age based on the date_of_birth" do
      user = create(:user, date_of_birth: 33.years.ago)
      expect(user.age).to eq(33)
    end
  end

  describe "#locale" do
    it "defaults to the default locale setting" do
      Setting["locales.default"] = "nl"

      user = build(:user, locale: nil)

      expect(user.locale).to eq "nl"
    end
  end

  describe "preferences" do
    describe "email_on_comment" do
      it "is false by default" do
        expect(subject.email_on_comment).to be false
      end
    end

    describe "email_on_comment_reply" do
      it "is false by default" do
        expect(subject.email_on_comment_reply).to be false
      end
    end

    describe "subscription_to_website_newsletter" do
      it "is true by default" do
        expect(subject.newsletter).to be true
      end
    end

    describe "email_digest" do
      it "is true by default" do
        expect(subject.email_digest).to be true
      end
    end

    describe "email_on_direct_message" do
      it "is true by default" do
        expect(subject.email_on_direct_message).to be true
      end
    end

    describe "official_position_badge" do
      it "is false by default" do
        expect(subject.official_position_badge).to be false
      end
    end
  end

  describe "administrator?" do
    it "is false when the user is not an admin" do
      expect(subject.administrator?).to be false
    end

    it "is true when the user is an admin" do
      subject.save!
      create(:administrator, user: subject)
      expect(subject.administrator?).to be true
    end
  end

  describe "moderator?" do
    it "is false when the user is not a moderator" do
      expect(subject.moderator?).to be false
    end

    it "is true when the user is a moderator" do
      subject.save!
      create(:moderator, user: subject)
      expect(subject.moderator?).to be true
    end
  end

  describe "valuator?" do
    it "is false when the user is not a valuator" do
      expect(subject.valuator?).to be false
    end

    it "is true when the user is a valuator" do
      subject.save!
      create(:valuator, user: subject)
      expect(subject.valuator?).to be true
    end
  end

  describe "manager?" do
    it "is false when the user is not a manager" do
      expect(subject.manager?).to be false
    end

    it "is true when the user is a manager" do
      subject.save!
      create(:manager, user: subject)
      expect(subject.manager?).to be true
    end
  end

  describe "sdg_manager?" do
    it "is false when the user is not a sdg manager" do
      expect(subject.sdg_manager?).to be false
    end

    it "is true when the user is a sdg manager" do
      subject.save!
      create(:sdg_manager, user: subject)
      expect(subject.sdg_manager?).to be true
    end
  end

  describe "poll_officer?" do
    it "is false when the user is not a poll officer" do
      expect(subject.poll_officer?).to be false
    end

    it "is true when the user is a poll officer" do
      subject.save!
      create(:poll_officer, user: subject)
      expect(subject.poll_officer?).to be true
    end
  end

  describe "organization?" do
    it "is false when the user is not an organization" do
      expect(subject.organization?).to be false
    end

    describe "when it is an organization" do
      before { create(:organization, user: subject) }

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
      expect(subject).not_to be_verified_organization
    end

    describe "when it is an organization" do
      before { create(:organization, user: subject) }

      it "is false when the user is not a verified organization" do
        expect(subject).not_to be_verified_organization
      end

      it "is true when the user is a verified organization" do
        subject.organization.verify
        expect(subject).to be_verified_organization
      end
    end
  end

  describe "organization_attributes" do
    before { subject.organization_attributes = { name: "org", responsible_name: "julia" } }

    it "triggers the creation of an associated organization" do
      expect(subject.organization).to be
      expect(subject.organization.name).to eq("org")
      expect(subject.organization.responsible_name).to eq("julia")
    end

    it "deactivates the validation of username, and activates the validation of organization" do
      subject.username = nil
      expect(subject).to be_valid

      subject.organization.name = nil
      expect(subject).not_to be_valid
    end
  end

  describe "official?" do
    it "is false when the user is not an official" do
      expect(subject.official_level).to eq(0)
      expect(subject.official?).to be false
    end

    it "is true when the user is an official" do
      subject.official_level = 3
      subject.save!
      expect(subject.official?).to be true
    end
  end

  describe "add_official_position!" do
    it "raises an exception when level not valid" do
      expect { subject.add_official_position!("Boss", 89) }.to raise_error ActiveRecord::RecordInvalid
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
      expect(subject.official_position).to be nil
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

      Setting["email_domain_for_officials"] = "officials.madrid.es"
      user1 = create(:user, email: "john@officials.madrid.es", confirmed_at: Time.current)
      user2 = create(:user, email: "john@yes.officials.madrid.es", confirmed_at: Time.current)
      user3 = create(:user, email: "john@unofficials.madrid.es", confirmed_at: Time.current)
      user4 = create(:user, email: "john@example.org", confirmed_at: Time.current)

      expect(user1.has_official_email?).to be true
      expect(user2.has_official_email?).to be true
      expect(user3.has_official_email?).to be false
      expect(user4.has_official_email?).to be false

      # We reset the officials' domain setting
      Setting.find_by(key: "email_domain_for_officials").update!(value: "")
    end
  end

  describe "official_position_badge" do
    describe "Users of level 1" do
      it "displays the badge if set in preferences" do
        user = create(:user, official_level: 1, official_position_badge: true)

        expect(user.display_official_position_badge?).to be true
      end

      it "does not display the badge if set in preferences" do
        user = create(:user, official_level: 1, official_position_badge: false)

        expect(user.display_official_position_badge?).to be false
      end
    end

    describe "Users higher than level 1" do
      it "displays the badge regardless of preferences" do
        user1 = create(:user, official_level: 2, official_position_badge: false)
        user2 = create(:user, official_level: 3, official_position_badge: false)
        user3 = create(:user, official_level: 4, official_position_badge: false)
        user4 = create(:user, official_level: 5, official_position_badge: false)

        expect(user1.display_official_position_badge?).to be true
        expect(user2.display_official_position_badge?).to be true
        expect(user3.display_official_position_badge?).to be true
        expect(user4.display_official_position_badge?).to be true
      end
    end
  end

  describe "scopes" do
    describe "active" do
      it "returns users that have not been erased" do
        user1 = create(:user, erased_at: nil)
        user2 = create(:user, erased_at: nil)
        user3 = create(:user, erased_at: Time.current)

        expect(User.active).to match_array [user1, user2]
        expect(User.active).not_to include(user3)
      end

      it "returns users that have not been blocked" do
        user1 = create(:user)
        user2 = create(:user)
        user3 = create(:user)
        user3.block

        expect(User.active).to match_array [user1, user2]
        expect(User.active).not_to include(user3)
      end
    end

    describe "erased" do
      it "returns users that have been erased" do
        user1 = create(:user, erased_at: Time.current)
        user2 = create(:user, erased_at: Time.current)
        user3 = create(:user, erased_at: nil)

        expect(User.erased).to match_array [user1, user2]
        expect(User.erased).not_to include(user3)
      end
    end

    describe ".by_username_email_or_document_number" do
      let!(:larry) do
        create(:user, email: "larry@consul.dev", username: "Larry Bird", document_number: "12345678Z")
      end

      before { create(:user, email: "robert@consul.dev", username: "Robert Parish") }

      it "finds users by email" do
        expect(User.by_username_email_or_document_number("larry@consul.dev")).to eq [larry]
      end

      it "finds users by email with whitespaces" do
        expect(User.by_username_email_or_document_number(" larry@consul.dev ")).to eq [larry]
      end

      it "finds users by name" do
        expect(User.by_username_email_or_document_number("larry")).to eq [larry]
      end

      it "finds users by name with whitespaces" do
        expect(User.by_username_email_or_document_number(" larry ")).to eq [larry]
      end

      it "finds users by document_number" do
        expect(User.by_username_email_or_document_number("12345678Z")).to eq [larry]
      end

      it "finds users by document_number with whitespaces" do
        expect(User.by_username_email_or_document_number(" 12345678Z ")).to eq [larry]
      end
    end

    describe ".between_ages" do
      it "returns users between certain ages, including both" do
        [21, 22, 23, 23, 42, 43, 44, 51].each do |age|
          create(:user, date_of_birth: age.years.ago)
        end

        expect(User.between_ages(0, 20).count).to eq 0
        expect(User.between_ages(0, 21).count).to eq 1
        expect(User.between_ages(21, 23).count).to eq 4
        expect(User.between_ages(24, 41).count).to eq 0
        expect(User.between_ages(41, 45).count).to eq 3
        expect(User.between_ages(51, 100).count).to eq 1
      end

      it "does not consider that people born in the same year share the same age" do
        april_1st_user = create(:user, date_of_birth: Time.zone.local(2001, 4, 1))
        april_2nd_user = create(:user, date_of_birth: Time.zone.local(2001, 4, 2))
        april_3rd_user = create(:user, date_of_birth: Time.zone.local(2001, 4, 3))

        travel_to "2021-04-02" do
          expect(User.between_ages(18, 19)).to eq [april_3rd_user]
          expect(User.between_ages(20, 21)).to match_array [april_1st_user, april_2nd_user]
          expect(User.between_ages(19, 20)).to match_array [april_1st_user, april_2nd_user, april_3rd_user]
        end
      end

      it "works on leap years with users born on leap years" do
        leap_day_user = create(:user, date_of_birth: Time.zone.local(2000, 2, 29))
        march_1st_user = create(:user, date_of_birth: Time.zone.local(2000, 3, 1))

        travel_to "2024-02-28" do
          expect(User.between_ages(22, 23)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(23, 24)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(24, 25)).to eq []
        end

        travel_to "2024-02-29" do
          expect(User.between_ages(22, 23)).to eq [march_1st_user]
          expect(User.between_ages(23, 24)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(24, 25)).to eq [leap_day_user]
        end

        travel_to "2024-03-01" do
          expect(User.between_ages(22, 23)).to eq []
          expect(User.between_ages(23, 24)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(24, 25)).to match_array [leap_day_user, march_1st_user]
        end
      end

      it "works on non-leap years with users born on leap years" do
        leap_day_user = create(:user, date_of_birth: Time.zone.local(2000, 2, 29))
        march_1st_user = create(:user, date_of_birth: Time.zone.local(2000, 3, 1))

        travel_to "2023-02-28" do
          expect(User.between_ages(21, 22)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(22, 23)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(23, 24)).to eq []
        end

        travel_to "2023-03-01" do
          expect(User.between_ages(21, 22)).to eq []
          expect(User.between_ages(22, 23)).to match_array [leap_day_user, march_1st_user]
          expect(User.between_ages(23, 24)).to match_array [leap_day_user, march_1st_user]
        end
      end

      it "works on leap years with users born on non-leap years" do
        march_1st_user = create(:user, date_of_birth: Time.zone.local(2001, 3, 1))

        travel_to "2024-02-28" do
          expect(User.between_ages(21, 22)).to eq [march_1st_user]
          expect(User.between_ages(22, 23)).to eq [march_1st_user]
          expect(User.between_ages(23, 24)).to eq []
        end

        travel_to "2024-02-29" do
          expect(User.between_ages(21, 22)).to eq [march_1st_user]
          expect(User.between_ages(22, 23)).to eq [march_1st_user]
          expect(User.between_ages(23, 24)).to eq []
        end

        travel_to "2024-03-01" do
          expect(User.between_ages(21, 22)).to eq []
          expect(User.between_ages(22, 23)).to match_array [march_1st_user]
          expect(User.between_ages(23, 24)).to match_array [march_1st_user]
        end
      end

      it "returns users between certain ages on a reference date" do
        reference_date = 20.years.ago

        travel_to(reference_date) do
          [21, 22, 23, 23, 34, 42, 43, 44, 50, 51].each do |age|
            create(:user, date_of_birth: age.years.ago)
          end
        end

        expect(User.between_ages(0, 20, at_time: reference_date).count).to eq 0
        expect(User.between_ages(21, 25, at_time: reference_date).count).to eq 4
        expect(User.between_ages(25, 30, at_time: reference_date).count).to eq 0
        expect(User.between_ages(30, 34, at_time: reference_date).count).to eq 1
        expect(User.between_ages(35, 39, at_time: reference_date).count).to eq 0
        expect(User.between_ages(40, 44, at_time: reference_date).count).to eq 3
        expect(User.between_ages(45, 49, at_time: reference_date).count).to eq 0
        expect(User.between_ages(50, 54, at_time: reference_date).count).to eq 2
        expect(User.between_ages(55, 100, at_time: reference_date).count).to eq 0
      end
    end
  end

  describe "self.search" do
    describe "find users" do
      let!(:larry) { create(:user, email: "larry@consul.dev", username: "Larry Bird") }

      before { create(:user, email: "robert@consul.dev", username: "Robert Parish") }

      it "by email" do
        expect(User.search("larry@consul.dev")).to eq [larry]
      end

      it "by email with whitespaces" do
        expect(User.search(" larry@consul.dev ")).to eq [larry]
      end

      it "by name" do
        expect(User.search("larry")).to eq [larry]
      end

      it "by name with whitespaces" do
        expect(User.search(" larry ")).to eq [larry]
      end
    end

    it "returns no results if no search term provided" do
      expect(User.search("    ")).to be_empty
    end
  end

  describe "verification" do
    it_behaves_like "verifiable"
  end

  describe "cache" do
    let(:user) { create(:user) }

    it "expires cache with becoming a moderator" do
      expect { create(:moderator, user: user) }.to change { user.cache_version }
    end

    it "expires cache with becoming an admin" do
      expect { create(:administrator, user: user) }.to change { user.cache_version }
    end

    it "expires cache with becoming a veridied organization" do
      create(:organization, user: user)
      expect { user.organization.verify }.to change { user.reload.cache_version }
    end
  end

  describe "document_number" do
    it "upcases document number" do
      user = User.new(document_number: "x1234567z")
      user.valid?
      expect(user.document_number).to eq("X1234567Z")
    end

    it "removes all characters except numbers and letters" do
      user = User.new(document_number: " 12.345.678 - B")
      user.valid?
      expect(user.document_number).to eq("12345678B")
    end
  end

  describe "#erase" do
    it "erases user information and marks him as erased" do
      user = create(:user,
                    username: "manolo",
                    email: "a@a.com",
                    unconfirmed_email: "a@a.com",
                    phone_number: "5678",
                    confirmed_phone: "5678",
                    unconfirmed_phone: "5678",
                    encrypted_password: "foobar",
                    confirmation_token: "token1",
                    reset_password_token: "token2",
                    email_verification_token: "token3")

      user.erase("a test")
      user.reload

      expect(user.erase_reason).to eq("a test")
      expect(user.erased_at).to    be

      expect(user.username).to be nil
      expect(user.email).to be nil
      expect(user.unconfirmed_email).to be nil
      expect(user.phone_number).to be nil
      expect(user.confirmed_phone).to be nil
      expect(user.unconfirmed_phone).to be nil
      expect(user.encrypted_password).to be_empty
      expect(user.confirmation_token).to be nil
      expect(user.reset_password_token).to be nil
      expect(user.email_verification_token).to be nil
    end

    it "maintains associated identification document" do
      user = create(:user, document_number: "1234", document_type: "1")
      user.erase
      user.reload

      expect(user.erased_at).to be
      expect(user.document_number).to be
      expect(user.document_type).to be
    end

    it "destroys associated social network identities" do
      user = create(:user)
      identity = create(:identity, user: user)

      user.erase("an identity test")

      expect(Identity.exists?(identity.id)).not_to be
    end

    it "removes all user roles" do
      user = create(:user)
      [:administrator, :moderator, :manager, :sdg_manager, :valuator].each do |role|
        create(role, user: user)
      end

      expect { user.erase }.to change { Administrator.count }.by(-1)
                           .and change { Moderator.count }.by(-1)
                           .and change { Manager.count }.by(-1)
                           .and change { SDG::Manager.count }.by(-1)
                           .and change { Valuator.count }.by(-1)
    end
  end

  describe "#take_votes_from" do
    it "logs info of previous users" do
      user = create(:user, :level_three)
      other_user = create(:user, :level_three)
      another_user = create(:user)

      expect(user.former_users_data_log).to be_blank

      user.take_votes_from other_user

      expect(user.former_users_data_log).to include("id: #{other_user.id}")

      user.take_votes_from another_user

      expect(user.former_users_data_log).to include("id: #{other_user.id}")
      expect(user.former_users_data_log).to include("| id: #{another_user.id}")
    end

    it "reassigns votes from other user" do
      other_user = create(:user, :level_three)
      user = create(:user, :level_three)

      v1 = create(:vote, voter: other_user, votable: create(:debate))
      v2 = create(:vote, voter: other_user, votable: create(:proposal))
      v3 = create(:vote, voter: other_user, votable: create(:comment))

      create(:vote)

      expect(other_user.votes.count).to eq(3)
      expect(user.votes.count).to eq(0)

      user.take_votes_from other_user

      expect(other_user.votes.count).to eq(0)
      expect(user.vote_ids).to match_array [v1.id, v2.id, v3.id]
    end

    it "reassigns budget ballots from other user" do
      other_user = create(:user, :level_three)
      user = create(:user, :level_three)

      b1 = create(:budget_ballot, user: other_user)
      b2 = create(:budget_ballot, user: other_user)

      create(:budget_ballot)

      expect(Budget::Ballot.where(user: other_user).count).to eq(2)
      expect(Budget::Ballot.where(user: user).count).to eq(0)

      user.take_votes_from other_user

      expect(Budget::Ballot.where(user: other_user).count).to eq(0)
      expect(Budget::Ballot.where(user: user)).to match_array [b1, b2]
    end

    it "reassigns poll voters from other user" do
      other_user = create(:user, :level_three)
      user = create(:user, :level_three)

      v1 = create(:poll_voter, user: other_user)
      v2 = create(:poll_voter, user: other_user)

      create(:poll_voter)

      expect(Poll::Voter.where(user: other_user).count).to eq(2)
      expect(Poll::Voter.where(user: user).count).to eq(0)

      user.take_votes_from other_user

      expect(Poll::Voter.where(user: other_user).count).to eq(0)
      expect(Poll::Voter.where(user: user)).to match_array [v1, v2]
    end

    it "does not reassign votes if the user has already voted" do
      poll = create(:poll)
      user = create(:user, :level_three)
      other_user = create(:user, :level_three)

      voter = create(:poll_voter, poll: poll, user: user)
      other_voter = create(:poll_voter, poll: poll, user: other_user)
      other_poll_voter = create(:poll_voter, poll: create(:poll), user: other_user)

      expect(Poll::Voter.where(user: user)).to eq [voter]
      expect(Poll::Voter.where(user: other_user)).to match_array [other_voter, other_poll_voter]

      user.take_votes_from(other_user)

      expect(Poll::Voter.where(user: user)).to match_array [voter, other_poll_voter]
      expect(Poll::Voter.where(user: other_user)).to eq []
    end
  end

  describe "#take_votes_if_erased_document" do
    it "does nothing if no erased user with received document" do
      user_1 = create(:user, :level_three)
      user_2 = create(:user, :level_three)

      create(:vote, voter: user_1)
      create(:budget_ballot, user: user_1)
      create(:poll_voter, user: user_1)

      user_2.take_votes_if_erased_document(111, 1)

      expect(user_1.votes.count).to eq(1)
      expect(user_2.votes.count).to eq(0)

      expect(Budget::Ballot.where(user: user_1).count).to eq(1)
      expect(Budget::Ballot.where(user: user_2).count).to eq(0)

      expect(Poll::Voter.where(user: user_1).count).to eq(1)
      expect(Poll::Voter.where(user: user_2).count).to eq(0)
    end

    it "takes votes from erased user with received document" do
      user_1 = create(:user, :level_two, document_number: "12345777", document_type: "1")
      user_2 = create(:user)

      create(:vote, voter: user_1)
      create(:budget_ballot, user: user_1)
      create(:poll_voter, user: user_1)

      user_1.erase

      user_2.take_votes_if_erased_document("12345777", "1")

      expect(user_1.votes.count).to eq(0)
      expect(user_2.votes.count).to eq(1)

      expect(Budget::Ballot.where(user: user_1).count).to eq(0)
      expect(Budget::Ballot.where(user: user_2).count).to eq(1)

      expect(Poll::Voter.where(user: user_1).count).to eq(0)
      expect(Poll::Voter.where(user: user_2).count).to eq(1)
    end

    it "removes document from erased user and logs info" do
      user_1 = create(:user, document_number: "12345777", document_type: "1")
      user_2 = create(:user)
      user_1.erase

      user_2.take_votes_if_erased_document("12345777", "1")

      expect(user_2.reload.former_users_data_log).to include("id: #{user_1.id}")
      expect(user_1.reload.document_number).to be_blank
    end
  end

  describe "email_required?" do
    it "is true for regular users" do
      expect(subject.email_required?).to be true
      expect(create(:user, :hidden).email_required?).to be true
    end

    it "is false for erased users" do
      user = create(:user)
      user.erase
      user.reload

      expect(user.email_required?).to be false
    end

    it "is false for verified users with no email" do
      user = create(:user, username: "Lois", email: "", verified_at: Time.current)

      expect(user).to be_valid
      expect(user.email_required?).to be false
    end
  end

  describe "#interests" do
    let(:user) { create(:user) }

    it "returns followed object tags" do
      create(:proposal, tag_list: "Sport", followers: [user])

      expect(user.interests).to eq ["Sport"]
    end

    it "deals gracefully with hidden proposals" do
      proposal = create(:proposal, tag_list: "Sport", followers: [user])

      proposal.hide

      expect(user.interests).to eq []
    end

    it "discards followed objects duplicated tags" do
      create(:proposal, tag_list: "Sport", followers: [user])
      create(:proposal, tag_list: "Sport", followers: [user])
      create(:budget_investment, tag_list: "Sport", followers: [user])

      expect(user.interests).to eq ["Sport"]
    end
  end

  describe "#public_interests" do
    it "is false by default" do
      expect(User.new.public_interests).to be false
    end
  end

  describe ".find_by_manager_login" do
    it "works with a low ID" do
      user = create(:user)
      expect(User.find_by_manager_login("admin_user_#{user.id}")).to eq user
    end

    it "works with a high ID" do
      10.times { create(:user) }
      user = User.last
      expect(User.find_by_manager_login("admin_user_#{user.id}")).to eq user
    end
  end

  describe "#block" do
    it "hides legislation proposals created by the user" do
      user = create(:user)
      other_user = create(:user)

      proposal = create(:legislation_proposal, author: user)
      other_proposal = create(:legislation_proposal, author: other_user)

      user.block

      expect(Legislation::Proposal.all).to eq [other_proposal]
      expect(Legislation::Proposal.with_hidden).to match_array [proposal, other_proposal]
    end

    it "removes all user roles" do
      user = create(:user)
      [:administrator, :moderator, :manager, :sdg_manager, :valuator].each do |role|
        create(role, user: user)
      end

      expect { user.block }.to change { Administrator.count }.by(-1)
                           .and change { Moderator.count }.by(-1)
                           .and change { Manager.count }.by(-1)
                           .and change { SDG::Manager.count }.by(-1)
                           .and change { Valuator.count }.by(-1)
    end
  end

  describe "#full_restore" do
    it "restore all previous hidden user content" do
      user = create(:user, :hidden)
      other_user = create(:user, :hidden)

      comment = create(:comment, :hidden, author: user)
      debate = create(:debate, :hidden, author: user)
      investment = create(:budget_investment, :hidden, author: user)
      proposal = create(:proposal, :hidden, author: user)
      legislation_proposal = create(:legislation_proposal, :hidden, author: user)
      proposal_notification = create(:proposal_notification, :hidden, proposal: proposal)

      old_hidden_comment = create(:comment, hidden_at: 3.days.ago, author: user)
      old_hidden_debate = create(:debate, hidden_at: 3.days.ago, author: user)
      old_hidden_investment = create(:budget_investment, hidden_at: 3.days.ago, author: user)
      old_hidden_proposal = create(:proposal, hidden_at: 3.days.ago, author: user)
      old_hidden_legislation_proposal = create(:legislation_proposal, hidden_at: 3.days.ago, author: user)
      old_hidden_proposal_notification = create(:proposal_notification,
                                                hidden_at: 3.days.ago,
                                                proposal: proposal)

      other_user_comment = create(:comment, :hidden, author: other_user)
      other_user_debate = create(:debate, :hidden, author: other_user)
      other_user_proposal = create(:proposal, :hidden, author: other_user)
      other_user_investment = create(:budget_investment, :hidden, author: other_user)
      other_user_legislation_proposal = create(:legislation_proposal, :hidden, author: other_user)
      other_user_proposal_notification = create(:proposal_notification,
                                                :hidden,
                                                proposal: other_user_proposal)

      user.full_restore

      expect(debate.reload).not_to be_hidden
      expect(comment.reload).not_to be_hidden
      expect(investment.reload).not_to be_hidden
      expect(proposal.reload).not_to be_hidden
      expect(proposal_notification.reload).not_to be_hidden
      expect(legislation_proposal.reload).not_to be_hidden

      expect(old_hidden_comment.reload).to be_hidden
      expect(old_hidden_debate.reload).to be_hidden
      expect(old_hidden_investment.reload).to be_hidden
      expect(old_hidden_proposal.reload).to be_hidden
      expect(old_hidden_proposal_notification.reload).to be_hidden
      expect(old_hidden_legislation_proposal.reload).to be_hidden

      expect(other_user_comment.reload).to be_hidden
      expect(other_user_debate.reload).to be_hidden
      expect(other_user_investment.reload).to be_hidden
      expect(other_user_proposal.reload).to be_hidden
      expect(other_user_proposal_notification.reload).to be_hidden
      expect(other_user_legislation_proposal.reload).to be_hidden
    end
  end

  describe "#add_subscriptions_token" do
    let(:user) { build(:user, subscriptions_token: nil) }

    it "generates a subscriptions token when the user doesn't have one" do
      user.add_subscriptions_token

      expect(user.subscriptions_token).to be_present
    end

    it "keeps the existing subscriptions token when the user already has one" do
      user.update!(subscriptions_token: "already_set")

      user.add_subscriptions_token

      expect(user.subscriptions_token).to eq "already_set"
    end
  end

  describe ".password_complexity" do
    it "returns no complexity when the secrets aren't configured" do
      expect(User.password_complexity).to eq({ digit: 0, lower: 0, symbol: 0, upper: 0 })
    end

    context "when secrets are configured" do
      before do
        stub_secrets(
          security: {
            password_complexity: true
          },
          tenants: {
            tolerant: {
              security: {
                password_complexity: false
              }
            }
          }
        )
      end

      it "uses the general secrets for the main tenant" do
        expect(User.password_complexity).to eq({ digit: 1, lower: 1, symbol: 0, upper: 1 })
      end

      it "uses the tenant secrets for a tenant" do
        allow(Tenant).to receive(:current_schema).and_return("tolerant")

        expect(User.password_complexity).to eq({ digit: 0, lower: 0, symbol: 0, upper: 0 })
      end
    end
  end

  describe ".maximum_attempts" do
    it "returns 20 as default when the secrets aren't configured" do
      expect(User.maximum_attempts).to eq 20
    end

    context "when secrets are configured" do
      before do
        stub_secrets(
          security: {
            lockable: { maximum_attempts: "14" }
          },
          tenants: {
            superstrict: {
              security: {
                lockable: { maximum_attempts: "1" }
              }
            }
          }
        )
      end

      it "uses the general secrets for the main tenant" do
        expect(User.maximum_attempts).to eq 14
      end

      it "uses the tenant secrets for a tenant" do
        allow(Tenant).to receive(:current_schema).and_return("superstrict")

        expect(User.maximum_attempts).to eq 1
      end
    end
  end

  describe ".unlock_in" do
    it "returns 1 as default when the secrets aren't configured" do
      expect(User.unlock_in).to eq 1.hour
    end

    context "when secrets are configured" do
      before do
        stub_secrets(
          security: {
            lockable: { unlock_in: "2" }
          },
          tenants: {
            superstrict: {
              security: {
                lockable: { unlock_in: "50" }
              }
            }
          }
        )
      end

      it "uses the general secrets for the main tenant" do
        expect(User.unlock_in).to eq 2.hours
      end

      it "uses the tenant secrets for a tenant" do
        allow(Tenant).to receive(:current_schema).and_return("superstrict")

        expect(User.unlock_in).to eq 50.hours
      end
    end
  end
  it_behaves_like "two_factor_authenticatable"
  it_behaves_like "two_factor_backupable"
  describe 'custom two-factor authentication logic' do
    let(:user) { create(:user) }
    let(:administrator) { create(:administrator).user } # Assumes you have an :administrator factory

    describe '#generate_two_factor_secret_if_missing!' do
      it 'generates an otp_secret if one does not exist' do
        user.otp_secret = nil
        expect { user.generate_two_factor_secret_if_missing! }.to change(user, :otp_secret).from(nil)
      end
      it 'does not generate a new otp_secret if one already exists' do
        # Arrange: set an initial secret
        user.update!(otp_secret: 'an_existing_secret')

        # Act: call the method again and reload the user to check persisted state
        user.generate_two_factor_secret_if_missing!
        user.reload

        # Assert: the secret should be the same as the initial one
        expect(user.otp_secret).to eq('an_existing_secret')
      end

    end

    describe '#enable_two_factor!' do
      it 'sets otp_required_for_login to true' do
        user.enable_two_factor!
        expect(user.otp_required_for_login).to be(true)
      end
    end

    describe '#disable_two_factor!' do
      before do
        user.enable_two_factor!
        user.generate_otp_backup_codes!
        user.save!
      end

      it 'sets otp_required_for_login to false' do
        user.disable_two_factor!
        expect(user.otp_required_for_login).to be(false)
      end

      it 'clears the otp_secret' do
        user.disable_two_factor!
        expect(user.otp_secret).to be_nil
      end

      it 'clears the otp_backup_codes' do
        user.disable_two_factor!
        expect(user.otp_backup_codes).to be_empty
      end
    end

#    describe '#otp_provisioning_uri' do
#      it 'returns a correctly formatted URI' do
#        user.otp_secret = 'BASE32SECRET'
#        uri = user.otp_provisioning_uri('test@example.com', issuer: 'TestApp')
#        expect(uri).to eq('otpauth://totp/TestApp:test@example.com?secret=BASE32SECRET&issuer=TestApp')
#      end
#    end

    describe '#requires_2fa?' do
      it 'returns true if the user is an administrator' do
        expect(administrator.requires_2fa?).to be(true)
      end

      it 'returns false if the user is not an administrator' do
        expect(user.requires_2fa?).to be(false)
      end
    end

    describe '#can_be_administrator?' do
      it 'returns true if 2FA is enabled' do
        user.otp_required_for_login = true
        expect(user.can_be_administrator?).to be(true)
      end

      it 'returns false if 2FA is not enabled' do
        user.otp_required_for_login = false
        expect(user.can_be_administrator?).to be(false)
      end
    end
  end
end
