require 'rails_helper'

describe Verification::Sms do
  it "should be valid" do
    sms = build(:verification_sms)
    expect(sms).to be_valid
  end

  it "should validate uniqness of phone" do
    user = create(:user, confirmed_phone: "699999999")
    sms = Verification::Sms.new(phone: "699999999")
    expect(sms).to_not be_valid
  end

end