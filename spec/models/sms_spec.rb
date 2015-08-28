require 'rails_helper'

describe Sms do
  it "should be valid" do
    sms = build(:sms)
    expect(sms).to be_valid
  end

  it "should validate uniqness of phone" do
    user = create(:user, confirmed_phone: "699999999")
    sms = Sms.new(phone: "699999999")
    expect(sms).to_not be_valid
  end

end