require 'rails_helper'

RSpec.describe RedeemableCode, type: :model do

  it "generate_token should create a 10 char token" do
    expect(RedeemableCode.generate_token.size).to eq 10
  end

  it "should be unique per geozone" do
    geozone = create(:geozone)
    token = RedeemableCode.generate_token
    RedeemableCode.create!(geozone_id: geozone.id, token: token)

    expect(RedeemableCode.new(geozone_id: geozone.id, token: token)).to_not be_valid
    expect(RedeemableCode.new(geozone_id: geozone.id + 1, token: token)).to be_valid
  end

end
