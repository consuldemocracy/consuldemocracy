require "rails_helper"

describe Poll::Stats do

  describe "Calculate stats" do
    it "Generate the correct stats" do
      poll = create(:poll)
      booth = create(:poll_booth)
      booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
      create(:poll_voter, poll: poll, origin: "web")
      3.times {create(:poll_voter, poll: poll, origin: "booth")}
      create(:poll_voter, poll: poll)
      create(:poll_recount, origin: "booth", white_amount: 1, null_amount: 0, total_amount: 2, booth_assignment_id: booth_assignment.id)
      stats = described_class.new(poll).generate

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