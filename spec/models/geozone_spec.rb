require 'rails_helper'

describe Geozone do
  let(:geozone) { build(:geozone) }

  it "should be valid" do
    expect(geozone).to be_valid
  end

  it "should not be valid without a name" do
    geozone.name = nil
    expect(geozone).to_not be_valid
  end

  describe "#safe_to_destroy?" do
    let(:geozone) { create(:geozone) }

    it "is true when not linked to other models" do
      expect(geozone.safe_to_destroy?).to be_truthy
    end

    it "is false when already linked to user" do
      create(:user, geozone: geozone)
      expect(geozone.safe_to_destroy?).to be_falsey
    end

    it "is false when already linked to proposal" do
      create(:proposal, geozone: geozone)
      expect(geozone.safe_to_destroy?).to be_falsey
    end

    it "is false when already linked to spending proposal" do
      create(:spending_proposal, geozone: geozone)
      expect(geozone.safe_to_destroy?).to be_falsey
    end

    it "is false when already linked to debate" do
      create(:debate, geozone: geozone)
      expect(geozone.safe_to_destroy?).to be_falsey
    end
  end
end
