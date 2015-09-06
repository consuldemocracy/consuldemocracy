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

  describe "user_is_locked?" do
    let(:user){ create :user }
    it "user is not locked for sms validation" do
      sms = build(:verification_sms, user: user)
      expect(sms.user_is_locked?).to be false
    end

    it "user is locked for sms validation after 3 attemps" do
      sms = build(:verification_sms, user: user)
      3.times { sms.increase_sms_tries }
      expect(sms.user_is_locked?).to be true
      #try two times to check the cache
      expect(sms.user_is_locked?).to be true
    end

    it "after 3 minutes the locked expires" do
      sms = build(:verification_sms, user: user)
      3.times { sms.increase_sms_tries }
      expect(sms.user_is_locked?).to be true
      Rails.cache.clear
      expect(sms.user_is_locked?).to be false

    end

  end
end