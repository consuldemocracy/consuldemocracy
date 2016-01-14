require 'rails_helper'

RSpec.describe Geozone, type: :model do
  let(:geozone) { build(:geozone) }

  it "should be valid" do
    expect(geozone).to be_valid
  end

  it "should not be valid without a name" do
    geozone.name = nil
    expect(geozone).to_not be_valid
  end
end
