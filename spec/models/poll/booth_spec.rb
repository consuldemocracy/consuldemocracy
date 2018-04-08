require 'rails_helper'

describe Poll::Booth do

  let(:booth) { build(:poll_booth) }

  it "is valid" do
    expect(booth).to be_valid
  end

  it "is not valid without a name" do
    booth.name = nil
    expect(booth).not_to be_valid
  end

  describe "#search" do
    it "finds booths searching by name or location" do
      booth1 = create(:poll_booth, name: "Booth number 1", location: "City center")
      booth2 = create(:poll_booth, name: "Central", location: "Town hall")

      expect(described_class.search("number")).to eq([booth1])
      expect(described_class.search("hall")).to eq([booth2])
      expect(described_class.search("cen").size).to eq 2
    end
  end

  describe "#available" do

    it "returns booths associated to current or incoming polls" do
      booth_for_current_poll  = create(:poll_booth)
      booth_for_incoming_poll = create(:poll_booth)
      booth_for_expired_poll  = create(:poll_booth)

      current_poll  = create(:poll, :current)
      incoming_poll = create(:poll, :incoming)
      expired_poll  = create(:poll, :expired)

      create(:poll_booth_assignment, poll: current_poll,  booth: booth_for_current_poll)
      create(:poll_booth_assignment, poll: incoming_poll, booth: booth_for_incoming_poll)
      create(:poll_booth_assignment, poll: expired_poll,  booth: booth_for_expired_poll)

      expect(described_class.available).to include(booth_for_current_poll)
      expect(described_class.available).to include(booth_for_incoming_poll)
      expect(described_class.available).not_to include(booth_for_expired_poll)
    end

  end
end
