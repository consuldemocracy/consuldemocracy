require 'rails_helper'

describe Meeting do
  let(:meeting) { build(:meeting) }

  it "should be valid" do
    expect(meeting).to be_valid
  end

  describe "validations" do
    it "should not be valid without an author" do
      meeting.author = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without a title" do
      meeting.title = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without a summary" do
      meeting.description = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without an address" do
      meeting.address = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without an address" do
      meeting.address = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without a held_at date" do
      meeting.held_at = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without a start_at time" do
      meeting.start_at = nil
      expect(meeting).to_not be_valid
    end

    it "should not be valid without a end_at time" do
      meeting.end_at = nil
      expect(meeting).to_not be_valid
    end
  end

  describe ".upcoming" do
    it "should return upcoming meetings based on held_at date" do
      meeting1 = create(:meeting, held_at: Date.yesterday)
      meeting2 = create(:meeting, held_at: Date.today)
      meeting3 = create(:meeting, held_at: Date.tomorrow)

      expect(Meeting.upcoming).to_not include(meeting1)
      expect(Meeting.upcoming).to include(meeting2)
      expect(Meeting.upcoming).to include(meeting3)
    end
  end
end
