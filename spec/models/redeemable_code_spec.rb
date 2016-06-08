require 'rails_helper'

describe RedeemableCode do

  it "generate_token should create a 10 char token" do
    expect(RedeemableCode.generate_token.size).to eq 10
  end

  it "is unique" do
    token = RedeemableCode.generate_token
    RedeemableCode.create!(token: token)

    expect(RedeemableCode.new(token: token)).to_not be_valid
  end

  describe "#redeemable?" do
    let(:token)   { 'token' }

    it "is true if a code is redeemable" do
      RedeemableCode.create!(token: token)

      expect(RedeemableCode.redeemable?(token)).to be
    end

    it "is false if a code doesn't exist" do
      expect(RedeemableCode.redeemable?(token)).to_not be
    end
  end

  describe "#redeem" do
    let(:token)   { 'token' }
    let(:user)    { create(:user) }

    it "when not redeemable, it returns false" do
      expect(RedeemableCode.redeem(token, user)).to_not be

      user.reload
      expect(user.redeemable_code).to be_nil
      expect(user).to_not be_level_three_verified
    end

    it "when redeemable, it deletes the code and updates the user" do
      RedeemableCode.create!(token: token)

      expect(RedeemableCode.redeem(token, user)).to be
      expect(RedeemableCode.redeemable?(token)).to_not be

      user.reload
      expect(user.redeemable_code).to eq(token)
      expect(user).to be_level_three_verified
    end
  end

end
