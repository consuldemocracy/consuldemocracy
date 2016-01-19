require 'rails_helper'

describe Meeting do
  let(:meeting) { build(:meeting) }

  it "should be valid" do
    expect(meeting).to be_valid
  end

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
