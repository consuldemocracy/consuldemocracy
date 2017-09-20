require 'rails_helper'

describe :shift do
  let(:shift) { build(:poll_shift) }

  describe "validations" do

    it "should be valid" do
      expect(shift).to be_valid
    end

    it "should not be valid without a booth" do
      shift.booth = nil
      expect(shift).to_not be_valid
    end

    it "should not be valid without an officer" do
      shift.officer = nil
      expect(shift).to_not be_valid
    end

    it "should not be valid without a date" do
      shift.date = nil
      expect(shift).to_not be_valid
    end

  end

  describe "officer_assignments" do

    it "should create corresponding officer_assignments" do
      poll1 = create(:poll)
      poll2 = create(:poll)
      poll3 = create(:poll)

      booth = create(:poll_booth)
      officer = create(:poll_officer)

      booth_assignment1 = create(:poll_booth_assignment, poll: poll1, booth: booth)
      booth_assignment2 = create(:poll_booth_assignment, poll: poll2, booth: booth)

      shift = create(:poll_shift, booth: booth, officer: officer, date: Date.current)

      officer_assignments = Poll::OfficerAssignment.all
      expect(officer_assignments.count).to eq(2)

      oa1 = officer_assignments.first
      oa2 = officer_assignments.second

      expect(oa1.officer).to eq(officer)
      expect(oa1.date).to eq(Date.current)
      expect(oa1.booth_assignment).to eq(booth_assignment1)

      expect(oa2.officer).to eq(officer)
      expect(oa2.date).to eq(Date.current)
      expect(oa2.booth_assignment).to eq(booth_assignment2)
    end

  end

  describe "#persist_data" do

    let(:user) { create(:user, username: "Ana", email: "ana@example.com") }
    let(:officer) { create(:poll_officer, user: user) }
    let(:shift) { create(:poll_shift, officer: officer) }

    it "should maintain officer data after destroying associated user" do
      shift.officer.user.destroy

      expect(shift.officer_name).to eq "Ana"
      expect(shift.officer_email).to eq "ana@example.com"
    end

    it "should maintain officer data after destroying officer role" do
      shift.officer.destroy

      expect(shift.officer_name).to eq "Ana"
      expect(shift.officer_email).to eq "ana@example.com"
    end

  end

end
