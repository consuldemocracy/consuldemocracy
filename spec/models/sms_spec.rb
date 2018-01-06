require 'rails_helper'

describe Verification::Sms do
  it "should be valid" do
    sms = build(:verification_sms)
    expect(sms).to be_valid
  end

  it "should validate uniqness of phone" do
    create(:user, confirmed_phone: "699999999")
    sms = described_class.new(phone: "699999999")
    expect(sms).to_not be_valid
  end

  it "only allows spaces, numbers and the + sign" do
    expect(build(:verification_sms, phone: "0034 666666666")).to be_valid
    expect(build(:verification_sms, phone: "+34 666666666")).to be_valid
    expect(build(:verification_sms, phone: "hello there")).to_not be_valid
    expect(build(:verification_sms, phone: "555; DROP TABLE USERS")).to_not be_valid
  end

end