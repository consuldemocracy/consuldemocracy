require 'rails_helper'

describe :poll do

  let(:poll) { build(:poll) }

  describe "validations" do
    it "should be valid" do
      expect(poll).to be_valid
    end

    it "should not be valid without a name" do
      poll.name = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without a start date" do
      poll.starts_at = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without an end date" do
      poll.ends_at = nil
      expect(poll).to_not be_valid
    end

    it "should not be valid without a proper start/end date range" do
      poll.starts_at = 1.week.ago
      poll.ends_at = 2.months.ago
      expect(poll).to_not be_valid
    end
  end

  describe "#opened?" do
    it "returns true only when it isn't too early or too late" do
      expect(create(:poll, :incoming)).to_not be_current
      expect(create(:poll, :expired)).to_not be_current
      expect(create(:poll)).to be_current
    end
  end

  describe "#incoming?" do
    it "returns true only when it is too early" do
      expect(create(:poll, :incoming)).to be_incoming
      expect(create(:poll, :expired)).to_not be_incoming
      expect(create(:poll)).to_not be_incoming
    end
  end

  describe "#expired?" do
    it "returns true only when it is too late" do
      expect(create(:poll, :incoming)).to_not be_expired
      expect(create(:poll, :expired)).to be_expired
      expect(create(:poll)).to_not be_expired
    end
  end

  describe "#published?" do
    it "returns true only when published is true" do
      expect(create(:poll)).to_not be_published
      expect(create(:poll, :published)).to be_published
    end
  end

  describe "#current_or_incoming" do
    it "returns current or incoming polls" do
      current = create(:poll, :current)
      incoming = create(:poll, :incoming)
      expired = create(:poll, :expired)

      current_or_incoming = Poll.current_or_incoming

      expect(current_or_incoming).to include(current)
      expect(current_or_incoming).to include(incoming)
      expect(current_or_incoming).to_not include(expired)
    end
  end

  describe "#recounting" do
    it "returns polls in recount & scrutiny phase" do
      current = create(:poll, :current)
      incoming = create(:poll, :incoming)
      expired = create(:poll, :expired)
      recounting = create(:poll, :recounting)

      recounting_polls = Poll.recounting

      expect(recounting_polls).to_not include(current)
      expect(recounting_polls).to_not include(incoming)
      expect(recounting_polls).to_not include(expired)
      expect(recounting_polls).to include(recounting)
    end
  end

  describe "#current_or_recounting_or_incoming" do
    it "returns current or recounting or incoming polls" do
      current = create(:poll, :current)
      incoming = create(:poll, :incoming)
      expired = create(:poll, :expired)
      recounting = create(:poll, :recounting)

      current_or_recounting_or_incoming = Poll.current_or_recounting_or_incoming

      expect(current_or_recounting_or_incoming).to include(current)
      expect(current_or_recounting_or_incoming).to include(recounting)
      expect(current_or_recounting_or_incoming).to include(incoming)
      expect(current_or_recounting_or_incoming).to_not include(expired)
    end
  end

  describe "answerable_by" do
    let(:geozone) {create(:geozone) }

    let!(:current_poll) { create(:poll) }
    let!(:expired_poll) { create(:poll, :expired) }
    let!(:incoming_poll) { create(:poll, :incoming) }
    let!(:current_restricted_poll) { create(:poll, geozone_restricted: true, geozones: [geozone]) }
    let!(:expired_restricted_poll) { create(:poll, :expired, geozone_restricted: true, geozones: [geozone]) }
    let!(:incoming_restricted_poll) { create(:poll, :incoming, geozone_restricted: true, geozones: [geozone]) }
    let!(:all_polls) { [current_poll, expired_poll, incoming_poll, current_poll, expired_restricted_poll, incoming_restricted_poll] }
    let(:non_current_polls) { [expired_poll, incoming_poll, expired_restricted_poll, incoming_restricted_poll] }

    let(:non_user) { nil }
    let(:level1)   { create(:user) }
    let(:level2)   { create(:user, :level_two) }
    let(:level2_from_geozone) { create(:user, :level_two, geozone: geozone) }
    let(:all_users) { [non_user, level1, level2, level2_from_geozone] }

    describe 'instance method' do
      it "rejects non-users and level 1 users" do
        all_polls.each do |poll|
          expect(poll).to_not be_answerable_by(non_user)
          expect(poll).to_not be_answerable_by(level1)
        end
      end

      it "rejects everyone when not current" do
        non_current_polls.each do |poll|
          all_users.each do |user|
            expect(poll).to_not be_answerable_by(user)
          end
        end
      end

      it "accepts level 2 users when unrestricted and current" do
        expect(current_poll).to be_answerable_by(level2)
        expect(current_poll).to be_answerable_by(level2_from_geozone)
      end

      it "accepts level 2 users only from the same geozone when restricted by geozone" do
        expect(current_restricted_poll).to_not be_answerable_by(level2)
        expect(current_restricted_poll).to be_answerable_by(level2_from_geozone)
      end
    end

    describe 'class method' do
      it "returns no polls for non-users and level 1 users" do
        expect(Poll.answerable_by(nil)).to be_empty
        expect(Poll.answerable_by(level1)).to be_empty
      end

      it "returns unrestricted polls for level 2 users" do
        expect(Poll.answerable_by(level2).to_a).to eq([current_poll])
      end

      it "returns restricted & unrestricted polls for level 2 users of the correct geozone" do
        list = Poll.answerable_by(level2_from_geozone)
                   .order(:geozone_restricted)
        expect(list.to_a).to eq([current_poll, current_restricted_poll])
      end
    end
  end

  describe "#voted_in_booth?" do

    it "returns true if the user has already voted in booth" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, poll: poll, user: user, origin: "booth")

      expect(poll.voted_in_booth?(user)).to be
    end

    it "returns false if the user has not already voted in a booth" do
      user = create(:user, :level_two)
      poll = create(:poll)

      expect(poll.voted_in_booth?(user)).to_not be
    end

    it "returns false if the user has voted in web" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, poll: poll, user: user, origin: "web")

      expect(poll.voted_in_booth?(user)).to_not be
    end

  end
end
