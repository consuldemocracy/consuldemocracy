require "rails_helper"

describe Poll::Booth do
  let(:booth) { build(:poll_booth) }

  it "is valid" do
    expect(booth).to be_valid
  end

  it "is not valid without a name" do
    booth.name = nil
    expect(booth).not_to be_valid
  end

  describe ".search" do
    it "finds booths searching by name or location" do
      booth1 = create(:poll_booth, name: "Booth number 1", location: "City center")
      booth2 = create(:poll_booth, name: "Central", location: "Town hall")

      expect(Poll::Booth.search("number")).to eq([booth1])
      expect(Poll::Booth.search("hall")).to eq([booth2])
      expect(Poll::Booth.search("cen")).to match_array [booth1, booth2]
    end

    it "returns all booths if search term is blank" do
      2.times { create(:poll_booth) }

      expect(Poll::Booth.search("").count).to eq 2
    end

    it "returns all booths if search term is nil" do
      2.times { create(:poll_booth) }

      expect(Poll::Booth.search(nil).count).to eq 2
    end
  end

  describe ".quick_search" do
    it "returns no booths if search term is blank" do
      create(:poll_booth)

      expect(Poll::Booth.quick_search("")).to be_empty
    end
  end

  describe ".available" do
    it "returns booths associated to current polls" do
      booth_for_current_poll = create(:poll_booth, polls: [create(:poll, :current)])
      booth_for_expired_poll = create(:poll_booth, polls: [create(:poll, :expired)])

      expect(Poll::Booth.available).to eq [booth_for_current_poll]
      expect(Poll::Booth.available).not_to include(booth_for_expired_poll)
    end

    it "returns polls with multiple translations only once" do
      create(:poll_booth, polls: [create(:poll, :current, name: "English", name_es: "Spanish")])

      expect(Poll::Booth.available.count).to eq 1
    end
  end
end
