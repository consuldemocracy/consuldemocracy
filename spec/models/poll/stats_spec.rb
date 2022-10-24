require "rails_helper"

describe Poll::Stats do
  let(:poll) { create(:poll) }
  let(:stats) { Poll::Stats.new(poll) }

  describe "#participants" do
    it "includes hidden users" do
      create(:poll_voter, poll: poll)
      create(:poll_voter, poll: poll, user: create(:user, :level_two, :hidden))

      expect(stats.participants.count).to eq(2)
    end
  end

  describe "total participants" do
    before { allow(stats).to receive(:total_web_white).and_return(1) }

    it "supports every channel" do
      3.times { create(:poll_voter, :from_web, poll: poll) }
      create(:poll_recount, :from_booth, poll: poll,
             total_amount: 8, white_amount: 4, null_amount: 1)

      expect(stats.total_participants_web).to eq(3)
      expect(stats.total_participants_booth).to eq(13)
      expect(stats.total_participants).to eq(16)
    end
  end

  describe "#total_participants_booth" do
    it "uses recounts even if there are discrepancies when recounting" do
      create(:poll_recount, :from_booth, poll: poll, total_amount: 1)
      2.times { create(:poll_voter, :from_booth, poll: poll) }

      expect(stats.total_participants_booth).to eq(1)
    end
  end

  describe "total participants percentage by channel" do
    it "is relative to the total amount of participants" do
      create(:poll_voter, :from_web, poll: poll)
      create(:poll_recount, :from_booth, poll: poll, total_amount: 5)

      expect(stats.total_participants_web_percentage).to eq(16.667)
      expect(stats.total_participants_booth_percentage).to eq(83.333)
    end
  end

  describe "#total_web_valid" do
    before { allow(stats).to receive(:total_web_white).and_return(1) }

    it "returns only valid votes" do
      3.times { create(:poll_voter, :from_web, poll: poll) }

      expect(stats.total_web_valid).to eq(2)
    end
  end

  describe "#total_web_null" do
    it "returns 0" do
      expect(stats.total_web_null).to eq(0)
    end
  end

  describe "#total_booth_valid" do
    it "sums the total amounts in the recounts" do
      create(:poll_recount, :from_booth, poll: poll, total_amount: 3, white_amount: 1)
      create(:poll_recount, :from_booth, poll: poll, total_amount: 4, null_amount: 2)

      expect(stats.total_booth_valid).to eq(7)
    end
  end

  describe "#total_booth_white" do
    it "sums the white amounts in the recounts" do
      create(:poll_recount, :from_booth, poll: poll, white_amount: 120, total_amount: 3)
      create(:poll_recount, :from_booth, poll: poll, white_amount: 203, null_amount: 5)

      expect(stats.total_booth_white).to eq(323)
    end
  end

  describe "#total_booth_null" do
    it "sums the null amounts in the recounts" do
      create(:poll_recount, :from_booth, poll: poll, null_amount: 125, total_amount: 3)
      create(:poll_recount, :from_booth, poll: poll, null_amount: 34, white_amount: 5)

      expect(stats.total_booth_null).to eq(159)
    end
  end

  describe "valid percentage by channel" do
    it "is relative to the total amount of valid votes" do
      create(:poll_recount, :from_booth, poll: poll, total_amount: 2)
      create(:poll_voter, :from_web, poll: poll)

      expect(stats.valid_percentage_web).to eq(33.333)
      expect(stats.valid_percentage_booth).to eq(66.667)
    end
  end

  describe "white percentage by channel" do
    before { allow(stats).to receive(:total_web_white).and_return(10) }

    it "is relative to the total amount of white votes" do
      create(:poll_recount, :from_booth, poll: poll, white_amount: 70)

      expect(stats.white_percentage_web).to eq(12.5)
      expect(stats.white_percentage_booth).to eq(87.5)
    end
  end

  describe "null percentage by channel" do
    it "only accepts null votes from booth" do
      create(:poll_recount, :from_booth, poll: poll, null_amount: 70)

      expect(stats.null_percentage_web).to eq(0)
      expect(stats.null_percentage_booth).to eq(100)
    end
  end

  describe "#total_valid_votes" do
    it "counts valid votes from every channel" do
      2.times { create(:poll_voter, :from_web, poll: poll) }
      create(:poll_recount, :from_booth, poll: poll, total_amount: 3, white_amount: 10)
      create(:poll_recount, :from_booth, poll: poll, total_amount: 4, null_amount: 20)

      expect(stats.total_valid_votes).to eq(9)
    end
  end

  describe "#total_white_votes" do
    before { allow(stats).to receive(:total_web_white).and_return(9) }

    it "counts white votes on every channel" do
      create(:poll_recount, :from_booth, poll: poll, white_amount: 12)

      expect(stats.total_white_votes).to eq(21)
    end
  end

  describe "#total_null_votes" do
    it "only accepts null votes from booth" do
      create(:poll_recount, :from_booth, poll: poll, null_amount: 32)

      expect(stats.total_null_votes).to eq(32)
    end
  end

  describe "total percentage by type" do
    before { allow(stats).to receive(:total_web_white).and_return(1) }

    it "is relative to the total amount of votes" do
      3.times { create(:poll_voter, :from_web, poll: poll) }
      create(:poll_recount, :from_booth, poll: poll,
             total_amount: 8, white_amount: 5, null_amount: 4)

      expect(stats.total_valid_percentage).to eq(50)
      expect(stats.total_white_percentage).to eq(30)
      expect(stats.total_null_percentage).to eq(20)
    end
  end

  describe "#participants_by_geozone" do
    it "groups by geozones in alphabetic order" do
      %w[Oceania Eurasia Eastasia].each { |name| create(:geozone, name: name) }

      expect(stats.participants_by_geozone.keys).to eq %w[Eastasia Eurasia Oceania]
    end

    it "calculates percentage relative to total participants" do
      hobbiton = create(:geozone, name: "Hobbiton")
      rivendel = create(:geozone, name: "Rivendel")

      3.times { create :poll_voter, poll: poll, user: create(:user, :level_two, geozone: hobbiton) }
      2.times { create :poll_voter, poll: poll, user: create(:user, :level_two, geozone: rivendel) }

      expect(stats.participants_by_geozone["Hobbiton"][:count]).to eq 3
      expect(stats.participants_by_geozone["Hobbiton"][:percentage]).to eq 60.0
      expect(stats.participants_by_geozone["Rivendel"][:count]).to eq 2
      expect(stats.participants_by_geozone["Rivendel"][:percentage]).to eq 40.0
    end
  end

  describe "#total_no_demographic_data" do
    before do
      create(:poll_voter, :from_web, poll: poll, user: create(:user, :level_two, gender: nil))
    end

    context "more registered participants than participants in recounts" do
      before do
        create(:poll_recount, :from_booth, poll: poll, total_amount: 1)
        2.times { create(:poll_voter, :from_booth, poll: poll) }
      end

      it "returns registered users with no demographic data" do
        expect(stats.total_no_demographic_data).to eq 1
      end
    end

    context "more participants in recounts than registered participants" do
      before do
        create(:poll_recount, :from_booth, poll: poll, total_amount: 3)
        2.times { create(:poll_voter, :from_booth, poll: poll) }
      end

      it "returns registered users with no demographic data plus users not registered" do
        expect(stats.total_no_demographic_data).to eq 2
      end
    end
  end

  describe "#channels" do
    context "no participants" do
      it "returns no channels" do
        expect(stats.channels).to eq []
      end
    end

    context "only participants from web" do
      before { create(:poll_voter, :from_web, poll: poll) }

      it "returns the web channel" do
        expect(stats.channels).to eq ["web"]
      end
    end

    context "only participants from booth" do
      before do
        create(:poll_recount, :from_booth, poll: poll, total_amount: 1)
      end

      it "returns the booth channel" do
        expect(stats.channels).to eq ["booth"]
      end
    end

    context "only participants from letter" do
      before { create(:poll_voter, origin: "letter", poll: poll) }

      it "returns the web channel" do
        expect(stats.channels).to eq ["letter"]
      end
    end

    context "participants from all channels" do
      before do
        create(:poll_voter, :from_web, poll: poll)
        create(:poll_recount, :from_booth, poll: poll, total_amount: 1)
        create(:poll_voter, origin: "letter", poll: poll)
      end

      it "returns all channels" do
        expect(stats.channels).to eq %w[web booth letter]
      end
    end
  end

  describe "#version", :with_frozen_time do
    context "record with no stats" do
      it "returns a string based on the current time" do
        expect(stats.version).to eq "v#{Time.current.to_i}"
      end

      it "doesn't overwrite the timestamp when called multiple times" do
        time = Time.current

        expect(stats.version).to eq "v#{time.to_i}"

        unfreeze_time

        travel_to 2.seconds.from_now do
          expect(stats.version).to eq "v#{time.to_i}"
        end
      end
    end

    context "record with stats" do
      before { poll.create_stats_version(updated_at: 1.day.ago) }

      it "returns the version of the existing stats" do
        expect(stats.version).to eq "v#{1.day.ago.to_i}"
      end
    end
  end
end
