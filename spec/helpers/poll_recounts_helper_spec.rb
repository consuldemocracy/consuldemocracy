require "rails_helper"

describe PollRecountsHelper do
  describe "#total_recounts_by_booth" do
    it "includes blank and null votes" do
      assignment = create(:poll_booth_assignment)
      create(:poll_recount, :from_booth, booth_assignment: assignment, total_amount: 3, white_amount: 1)
      create(:poll_recount, :from_booth, booth_assignment: assignment, total_amount: 4, null_amount: 2)

      expect(total_recounts_by_booth(assignment)).to eq 10
    end
  end
end
