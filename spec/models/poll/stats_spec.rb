require "rails_helper"

describe Poll::Stats do
  let(:poll) { create(:poll) }
  let(:stats) { Poll::Stats.new(poll) }

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

  describe "#total_web_white" do
    pending "Too complex to test"
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

      expect(stats.participants_by_geozone["Hobbiton"][:total]).to eq(count: 3, percentage: 60.0)
      expect(stats.participants_by_geozone["Rivendel"][:total]).to eq(count: 2, percentage: 40.0)
    end

    it "calculates percentage relative to the geozone population" do
      midgar = create(:geozone, name: "Midgar")

      create(:poll_voter, poll: poll, user: create(:user, :level_two, geozone: midgar))
      2.times { create :user, :level_two, geozone: midgar }

      expect(stats.participants_by_geozone["Midgar"][:percentage]).to eq(33.333)
    end

    describe "participants by gender and channel" do
      before do
        4.times do
          create :poll_voter, :from_web, poll: poll,
                  user: create(:user, :level_two, gender: "female")
        end

        3.times do
          create :poll_voter, :from_web, poll: poll,
                  user: create(:user, :level_two, gender: "male")
        end

        2.times do
          create :poll_voter, :from_booth, poll: poll,
                  user: create(:user, :level_two, gender: "female")
        end

        1.times do
          create :poll_voter, :from_booth, poll: poll,
                  user: create(:user, :level_two, gender: "male")
        end
      end

      it "calculates total participants" do
        expect(stats.total_female_web).to eq(4)
        expect(stats.total_male_web).to eq(3)
        expect(stats.total_female_booth).to eq(2)
        expect(stats.total_male_booth).to eq(1)
      end

      it "calculates percentage relative to the participants for that gender" do
        expect(stats.female_web_percentage).to eq(66.667)
        expect(stats.female_booth_percentage).to eq(33.333)

        expect(stats.male_web_percentage).to eq(75.0)
        expect(stats.male_booth_percentage).to eq(25.0)
      end
    end

    describe "participants by age and channel" do
      before do
        4.times do
          create :poll_voter, :from_web, poll: poll,
                 user: create(:user, :level_two, date_of_birth: 37.years.ago)
        end

        3.times do
          create :poll_voter, :from_web, poll: poll,
                 user: create(:user, :level_two, date_of_birth: 52.years.ago)
        end

        2.times do
          create :poll_voter, :from_booth, poll: poll,
                 user: create(:user, :level_two, date_of_birth: 37.years.ago)
        end

        1.times do
          create :poll_voter, :from_booth, poll: poll,
                 user: create(:user, :level_two, date_of_birth: 52.years.ago)
        end
      end

      it "calculates the count of users by channel and age" do
        expect(stats.web_participants_by_age["35 - 39"][:count]).to eq(4)
        expect(stats.web_participants_by_age["50 - 54"][:count]).to eq(3)
        expect(stats.booth_participants_by_age["35 - 39"][:count]).to eq(2)
        expect(stats.booth_participants_by_age["50 - 54"][:count]).to eq(1)
      end

      it "calculates percentage relative to the participants for that age" do
        expect(stats.web_participants_by_age["35 - 39"][:percentage]).to eq(66.667)
        expect(stats.booth_participants_by_age["35 - 39"][:percentage]).to eq(33.333)

        expect(stats.web_participants_by_age["50 - 54"][:percentage]).to eq(75.0)
        expect(stats.booth_participants_by_age["50 - 54"][:percentage]).to eq(25.0)
      end
    end
  end

  describe "#generate" do
    it "generates the correct stats" do
      poll = create(:poll)
      2.times { create(:poll_voter, :from_web, poll: poll) }
      3.times { create(:poll_voter, :from_booth, poll: poll) }
      create(:poll_recount, :from_booth, poll: poll,
             white_amount: 1, null_amount: 0, total_amount: 2)

      stats = Poll::Stats.new(poll).generate

      expect(stats[:total_participants]).to eq(5)
      expect(stats[:total_participants_web]).to eq(2)
      expect(stats[:total_participants_booth]).to eq(3)
      expect(stats[:total_valid_votes]).to eq(4)
      expect(stats[:total_white_votes]).to eq(1)
      expect(stats[:total_null_votes]).to eq(0)

      expect(stats[:total_web_valid]).to eq(2)
      expect(stats[:total_web_white]).to eq(0)
      expect(stats[:total_web_null]).to eq(0)

      expect(stats[:total_booth_valid]).to eq(2)
      expect(stats[:total_booth_white]).to eq(1)
      expect(stats[:total_booth_null]).to eq(0)

      expect(stats[:total_participants_web_percentage]).to eq(40)
      expect(stats[:total_participants_booth_percentage]).to eq(60)
      expect(stats[:valid_percentage_web]).to eq(50)
      expect(stats[:white_percentage_web]).to eq(0)
      expect(stats[:null_percentage_web]).to eq(0)
      expect(stats[:valid_percentage_booth]).to eq(50)
      expect(stats[:white_percentage_booth]).to eq(100)
      expect(stats[:null_percentage_booth]).to eq(0)
      expect(stats[:total_valid_percentage]).to eq(80)
      expect(stats[:total_white_percentage]).to eq(20)
      expect(stats[:total_null_percentage]).to eq(0)
    end
  end

end