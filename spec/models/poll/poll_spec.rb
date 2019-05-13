require "rails_helper"

describe Poll do

  let(:poll) { build(:poll) }

  describe "Concerns" do
    it_behaves_like "notifiable"
  end

  describe "validations" do
    it "is valid" do
      expect(poll).to be_valid
    end

    it "is not valid without a name" do
      poll.name = nil
      expect(poll).not_to be_valid
    end

    it "is not valid without a start date" do
      poll.starts_at = nil
      expect(poll).not_to be_valid
    end

    it "is not valid without an end date" do
      poll.ends_at = nil
      expect(poll).not_to be_valid
    end

    it "is not valid without a proper start/end date range" do
      poll.starts_at = 1.week.ago
      poll.ends_at = 2.months.ago
      expect(poll).not_to be_valid
    end

    it "no overlapping polls for proposal polls are allowed" do
    end
  end

  describe "proposal polls specific validations" do
    let(:proposal) { create(:proposal) }
    let(:poll) { build(:poll, related: proposal) }

    it "is valid when overlapping but different proposals" do
      other_proposal = create(:proposal)
      _other_poll = create(:poll, related: other_proposal, starts_at: poll.starts_at,
                                                           ends_at: poll.ends_at)

      expect(poll).to be_valid
    end

    it "is valid when same proposal but not overlapping" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.ends_at + 1.day,
                                                     ends_at: poll.ends_at + 8.days)
      expect(poll).to be_valid
    end

    it "is not valid when overlaps from the beginning" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.starts_at - 8.days,
                                                     ends_at: poll.starts_at)
      expect(poll).not_to be_valid
    end

    it "is not valid when overlaps from the end" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.ends_at,
                                                     ends_at: poll.ends_at + 8.days)
      expect(poll).not_to be_valid
    end

    it "is not valid when overlaps with same interval" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.starts_at,
                                                     ends_at: poll.ends_at)
      expect(poll).not_to be_valid
    end

    it "is not valid when overlaps with interval contained" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.starts_at + 1.day,
                                                     ends_at: poll.ends_at - 1.day)
      expect(poll).not_to be_valid
    end

    it "is not valid when overlaps with interval containing" do
      _other_poll = create(:poll, related: proposal, starts_at: poll.starts_at - 8.days,
                                                     ends_at: poll.ends_at + 8.days)
      expect(poll).not_to be_valid
    end
  end

  describe "#opened?" do
    it "returns true only when it isn't too late" do
      expect(create(:poll, :expired)).not_to be_current
      expect(create(:poll)).to be_current
    end
  end

  describe "#expired?" do
    it "returns true only when it is too late" do
      expect(create(:poll, :expired)).to be_expired
      expect(create(:poll)).not_to be_expired
    end
  end

  describe "#published?" do
    it "returns true only when published is true" do
      expect(create(:poll)).not_to be_published
      expect(create(:poll, :published)).to be_published
    end
  end

  describe "#recounting" do
    it "returns polls in recount & scrutiny phase" do
      current = create(:poll, :current)
      expired = create(:poll, :expired)
      recounting = create(:poll, :recounting)

      recounting_polls = described_class.recounting

      expect(recounting_polls).not_to include(current)
      expect(recounting_polls).not_to include(expired)
      expect(recounting_polls).to include(recounting)
    end
  end

  describe "#current_or_recounting" do
    it "returns current or recounting polls" do
      current = create(:poll, :current)
      expired = create(:poll, :expired)
      recounting = create(:poll, :recounting)

      current_or_recounting = described_class.current_or_recounting

      expect(current_or_recounting).to include(current)
      expect(current_or_recounting).to include(recounting)
      expect(current_or_recounting).not_to include(expired)
    end
  end

  describe "answerable_by" do
    let(:geozone) {create(:geozone) }

    let!(:current_poll) { create(:poll) }
    let!(:expired_poll) { create(:poll, :expired) }

    let!(:current_restricted_poll) { create(:poll, geozone_restricted: true, geozones: [geozone]) }
    let!(:expired_restricted_poll) { create(:poll, :expired, geozone_restricted: true,
                                                             geozones: [geozone]) }

    let!(:all_polls) { [current_poll, expired_poll, current_poll, expired_restricted_poll] }
    let(:non_current_polls) { [expired_poll, expired_restricted_poll] }

    let(:non_user) { nil }
    let(:level1)   { create(:user) }
    let(:level2)   { create(:user, :level_two) }
    let(:level2_from_geozone) { create(:user, :level_two, geozone: geozone) }
    let(:all_users) { [non_user, level1, level2, level2_from_geozone] }

    describe "instance method" do
      it "rejects non-users and level 1 users" do
        all_polls.each do |poll|
          expect(poll).not_to be_answerable_by(non_user)
          expect(poll).not_to be_answerable_by(level1)
        end
      end

      it "rejects everyone when not current" do
        non_current_polls.each do |poll|
          all_users.each do |user|
            expect(poll).not_to be_answerable_by(user)
          end
        end
      end

      it "accepts level 2 users when unrestricted and current" do
        expect(current_poll).to be_answerable_by(level2)
        expect(current_poll).to be_answerable_by(level2_from_geozone)
      end

      it "accepts level 2 users only from the same geozone when restricted by geozone" do
        expect(current_restricted_poll).not_to be_answerable_by(level2)
        expect(current_restricted_poll).to be_answerable_by(level2_from_geozone)
      end
    end

    describe "class method" do
      it "returns no polls for non-users and level 1 users" do
        expect(described_class.answerable_by(nil)).to be_empty
        expect(described_class.answerable_by(level1)).to be_empty
      end

      it "returns unrestricted polls for level 2 users" do
        expect(described_class.answerable_by(level2).to_a).to eq([current_poll])
      end

      it "returns restricted & unrestricted polls for level 2 users of the correct geozone" do
        list = described_class.answerable_by(level2_from_geozone)
                              .order(:geozone_restricted)
        expect(list.to_a).to eq([current_poll, current_restricted_poll])
      end
    end
  end

  describe "votable_by" do
    it "returns polls that have not been voted by a user" do
      user = create(:user, :level_two)

      poll1 = create(:poll)
      poll2 = create(:poll)
      poll3 = create(:poll)

      create(:poll_voter, user: user, poll: poll1)

      expect(Poll.votable_by(user)).to include(poll2)
      expect(Poll.votable_by(user)).to include(poll3)
      expect(Poll.votable_by(user)).not_to include(poll1)
    end

    it "returns polls that are answerable by a user" do
      user = create(:user, :level_two, geozone: nil)
      poll1 = create(:poll)
      poll2 = create(:poll)

      allow(Poll).to receive(:answerable_by).and_return(Poll.where(id: poll1))

      expect(Poll.votable_by(user)).to include(poll1)
      expect(Poll.votable_by(user)).not_to include(poll2)
    end

    it "returns polls even if there are no voters yet" do
      user = create(:user, :level_two)
      poll = create(:poll)

      expect(Poll.votable_by(user)).to include(poll)
    end

  end

  describe "#votable_by" do
    it "returns false if the user has already voted the poll" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, user: user, poll: poll)

      expect(poll.votable_by?(user)).to eq(false)
    end

    it "returns false if the poll is not answerable by the user" do
      user = create(:user, :level_two)
      poll = create(:poll)

      allow_any_instance_of(Poll).to receive(:answerable_by?).and_return(false)

      expect(poll.votable_by?(user)).to eq(false)
    end

    it "return true if a poll is answerable and has not been voted by the user" do
      user = create(:user, :level_two)
      poll = create(:poll)

      allow_any_instance_of(Poll).to receive(:answerable_by?).and_return(true)

      expect(poll.votable_by?(user)).to eq(true)
    end
  end

  describe "#voted_by?" do
    it "return false if the user has not voted for this poll" do
      user = create(:user, :level_two)
      poll = create(:poll)

      expect(poll.voted_by?(user)).to eq(false)
    end

    it "returns true if the user has voted for this poll" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, user: user, poll: poll)

      expect(poll.voted_by?(user)).to eq(true)
    end
  end

  describe "#voted_in_booth?" do
    it "returns true if the user has already voted in booth" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, :from_booth, poll: poll, user: user)

      expect(poll.voted_in_booth?(user)).to be
    end

    it "returns false if the user has not already voted in a booth" do
      user = create(:user, :level_two)
      poll = create(:poll)

      expect(poll.voted_in_booth?(user)).not_to be
    end

    it "returns false if the user has voted in web" do
      user = create(:user, :level_two)
      poll = create(:poll)

      create(:poll_voter, :from_web, poll: poll, user: user)

      expect(poll.voted_in_booth?(user)).not_to be
    end
  end

  describe ".overlaping_with" do
    let(:proposal) { create :proposal }
    let(:other_proposal) { create :proposal }
    let(:poll) { create(:poll, related: proposal) }
    let(:overlaping_poll) { build(:poll, related: proposal, starts_at: poll.starts_at + 1.day,
                                                            ends_at: poll.ends_at - 1.day) }
    let(:non_overlaping_poll) { create(:poll, related: proposal, starts_at: poll.ends_at + 1.day,
                                                                 ends_at: poll.ends_at + 31.days) }
    let(:overlaping_poll_2) { create(:poll, related: other_proposal,
                                            starts_at: poll.starts_at + 1.day,
                                            ends_at: poll.ends_at - 1.day) }

    it "a poll can not overlap itself" do
      expect(Poll.overlaping_with(poll)).not_to include(poll)
    end

    it "returns overlaping polls for the same proposal" do
      expect(Poll.overlaping_with(overlaping_poll)).to include(poll)
    end

    it "do not returs non overlaping polls for the same proposal" do
      expect(Poll.overlaping_with(poll)).not_to include(non_overlaping_poll)
    end

    it "do not returns overlaping polls for other proposal" do
      expect(Poll.overlaping_with(poll)).not_to include(overlaping_poll_2)
    end
  end

  context "scopes" do

    describe "#not_budget" do

      it "returns polls not associated to a budget" do
        budget = create(:budget)

        poll1 = create(:poll)
        poll2 = create(:poll)
        poll3 = create(:poll, budget: budget)

        expect(Poll.not_budget).to include(poll1)
        expect(Poll.not_budget).to include(poll2)
        expect(Poll.not_budget).not_to include(poll3)
      end

    end

  end

end
