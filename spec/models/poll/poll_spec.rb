require "rails_helper"

describe Poll do
  let(:poll) { build(:poll) }

  describe "Concerns" do
    it_behaves_like "notifiable"
    it_behaves_like "acts as paranoid", :poll
    it_behaves_like "reportable"
    it_behaves_like "globalizable", :poll
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

      recounting_polls = Poll.recounting

      expect(recounting_polls).to eq [recounting]
      expect(recounting_polls).not_to include(current)
      expect(recounting_polls).not_to include(expired)
    end
  end

  describe "#current_or_recounting" do
    it "returns current or recounting polls" do
      current = create(:poll, :current)
      expired = create(:poll, :expired)
      recounting = create(:poll, :recounting)

      current_or_recounting = Poll.current_or_recounting

      expect(current_or_recounting).to match_array [current, recounting]
      expect(current_or_recounting).not_to include(expired)
    end
  end

  describe "answerable_by" do
    let(:geozone) { create(:geozone) }

    let!(:current_poll) { create(:poll) }
    let!(:expired_poll) { create(:poll, :expired) }

    let!(:current_restricted_poll) { create(:poll, geozone_restricted: true, geozones: [geozone]) }
    let!(:expired_restricted_poll) do
      create(:poll, :expired, geozone_restricted: true, geozones: [geozone])
    end

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

  describe "votable_by" do
    it "returns polls that have not been voted by a user" do
      user = create(:user, :level_two)

      poll1 = create(:poll)
      poll2 = create(:poll)
      poll3 = create(:poll)

      create(:poll_voter, user: user, poll: poll1)

      expect(Poll.votable_by(user)).to match_array [poll2, poll3]
    end

    it "returns polls that are answerable by a user" do
      user = create(:user, :level_two, geozone: nil)
      poll1 = create(:poll)
      poll2 = create(:poll)

      allow(Poll).to receive(:answerable_by).and_return(Poll.where(id: poll1))

      expect(Poll.votable_by(user)).to eq [poll1]
      expect(Poll.votable_by(user)).not_to include(poll2)
    end

    it "returns polls even if there are no voters yet" do
      user = create(:user, :level_two)
      poll = create(:poll)

      expect(Poll.votable_by(user)).to eq [poll]
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
    let(:overlaping_poll) do
      build(:poll, related: proposal, starts_at: poll.starts_at + 1.day, ends_at: poll.ends_at - 1.day)
    end

    let(:non_overlaping_poll) do
      create(:poll, related: proposal, starts_at: poll.ends_at + 1.day, ends_at: poll.ends_at + 31.days)
    end

    let(:overlaping_poll_2) do
      create(:poll, related: other_proposal, starts_at: poll.starts_at + 1.day, ends_at: poll.ends_at - 1.day)
    end

    it "a poll can not overlap itself" do
      expect(Poll.overlaping_with(poll)).not_to include(poll)
    end

    it "returns overlaping polls for the same proposal" do
      expect(Poll.overlaping_with(overlaping_poll)).to eq [poll]
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
        poll1 = create(:poll)
        poll2 = create(:poll)
        poll3 = create(:poll, :for_budget)

        expect(Poll.not_budget).to match_array [poll1, poll2]
        expect(Poll.not_budget).not_to include(poll3)
      end
    end
  end

  describe "#sort_for_list" do
    it "returns polls sorted by name ASC" do
      starts_at = Time.current + 1.day
      poll1 = create(:poll, geozone_restricted: true, starts_at: starts_at, name: "Zzz...")
      poll2 = create(:poll, geozone_restricted: true, starts_at: starts_at, name: "Mmmm...")
      poll3 = create(:poll, geozone_restricted: true, starts_at: starts_at, name: "Aaaaah!")

      expect(Poll.sort_for_list).to eq [poll3, poll2, poll1]
    end

    it "returns not geozone restricted polls first" do
      starts_at = Time.current + 1.day
      poll1 = create(:poll, geozone_restricted: false, starts_at: starts_at, name: "Zzz...")
      poll2 = create(:poll, geozone_restricted: true, starts_at: starts_at, name: "Aaaaaah!")

      expect(Poll.sort_for_list).to eq [poll1, poll2]
    end

    it "returns polls earlier to start first" do
      starts_at = Time.current + 1.day
      poll1 = create(:poll, geozone_restricted: false, starts_at: starts_at - 1.hour, name: "Zzz...")
      poll2 = create(:poll, geozone_restricted: false, starts_at: starts_at, name: "Aaaaah!")

      expect(Poll.sort_for_list).to eq [poll1, poll2]
    end

    it "returns polls with multiple translations only once" do
      create(:poll, name_en: "English", name_es: "Spanish")

      expect(Poll.sort_for_list.count).to eq 1
    end

    context "fallback locales" do
      before do
        allow(I18n.fallbacks).to receive(:[]).and_return([:es])
        Globalize.set_fallbacks_to_all_available_locales
      end

      it "orders by name considering fallback locales" do
        starts_at = Time.current + 1.day
        poll1 = create(:poll, starts_at: starts_at, name: "Charlie")
        poll2 = create(:poll, starts_at: starts_at, name: "Delta")
        poll3 = I18n.with_locale(:es) do
          create(:poll, starts_at: starts_at, name: "Zzz...", name_fr: "Aaaah!")
        end
        poll4 = I18n.with_locale(:es) do
          create(:poll, starts_at: starts_at, name: "Bravo")
        end

        expect(Poll.sort_for_list).to eq [poll4, poll1, poll2, poll3]
      end
    end
  end

  describe "#recounts_confirmed" do
    it "is false for current polls" do
      poll = create(:poll, :current)

      expect(poll.recounts_confirmed?).to be false
    end

    it "is false for recounting polls" do
      poll = create(:poll, :recounting)

      expect(poll.recounts_confirmed?).to be false
    end

    it "is false for polls which finished less than a month ago" do
      poll = create(:poll, starts_at: 3.months.ago, ends_at: 27.days.ago)

      expect(poll.recounts_confirmed?).to be false
    end

    it "is true for polls which finished more than a month ago" do
      poll = create(:poll, starts_at: 3.months.ago, ends_at: 1.month.ago - 1.day)

      expect(poll.recounts_confirmed?).to be true
    end
  end

  describe ".search" do
    let!(:square) do
      create(:poll, name: "Square reform", summary: "Next to the park", description: "Give it more space")
    end

    let!(:park) do
      create(:poll, name: "New park", summary: "Green spaces", description: "Next to the square")
    end

    it "returns only matching polls" do
      expect(Poll.search("reform")).to eq [square]
      expect(Poll.search("green")).to eq [park]
      expect(Poll.search("nothing here")).to be_empty
    end

    it "gives more weight to name" do
      expect(Poll.search("square")).to eq [square, park]
      expect(Poll.search("park")).to eq [park, square]
    end

    it "gives more weight to summary than description" do
      expect(Poll.search("space")).to eq [park, square]
    end
  end
end
