require "rails_helper"

describe Verification::Sms do
  it "is valid" do
    sms = build(:verification_sms)
    expect(sms).to be_valid
  end

  it "validates uniqness of phone" do
    create(:user, confirmed_phone: "699999999")
    sms = described_class.new(phone: "699999999")
    expect(sms).not_to be_valid
  end

  it "only allows spaces, numbers and the + sign" do
    expect(build(:verification_sms, phone: "0034 666666666")).to be_valid
    expect(build(:verification_sms, phone: "+34 666666666")).to be_valid
    expect(build(:verification_sms, phone: "hello there")).not_to be_valid
    expect(build(:verification_sms, phone: "555; DROP TABLE USERS")).not_to be_valid
  end

end