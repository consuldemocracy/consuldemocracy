require 'rails_helper'

describe :booth do

  let(:booth) { build(:poll_booth) }

  it "should be valid" do
    expect(booth).to be_valid
  end

  it "should not be valid without a name" do
    booth.name = nil
    expect(booth).to_not be_valid
  end

  describe "#search" do
    it "should find booths searching by name or location" do
      booth1 = create(:poll_booth, name: "Booth number 1", location: "City center")
      booth2 = create(:poll_booth, name: "Central", location: "Town hall")

      expect(Poll::Booth.search("number")).to eq([booth1])
      expect(Poll::Booth.search("hall")).to eq([booth2])
      expect(Poll::Booth.search("cen").size).to eq 2
    end
  end

end