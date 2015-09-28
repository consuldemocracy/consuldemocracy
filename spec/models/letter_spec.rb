require 'rails_helper'

describe 'Verification::Letter' do

  let(:user)   { create(:user)  }

  describe "validations" do

    let(:letter) { build(:verification_letter) }

    it "should be valid" do
      expect(letter).to be_valid
    end

    it "should not be valid without a user" do
      letter.user = nil
      expect(letter).to_not be_valid
    end

  end

  describe "save" do

    before(:each) do
      letter = Verification::Letter.new(user: user)
      letter.save
      user.reload
    end

    it "should update letter_requested" do
      expect(user.letter_requested_at).to be
    end

  end

  describe "#verified?" do

    let(:letter) { build(:verification_letter) }

    it "letter not sent" do
      letter.user.update(letter_sent_at: nil)

      expect(letter.verified?).to eq(false)
      expect(letter.errors[:verification_code].first).to eq("We have not sent you the letter with the code yet")
    end

    it "letter sent but incorrect code" do
      letter.user.update(letter_sent_at: 1.day.ago, letter_verification_code: "123456")
      letter.verification_code = nil

      expect(letter.verified?).to eq(false)
      expect(letter.errors[:verification_code].first).to eq("Incorrect confirmation code")
    end

    it "letter sent and correct code" do
      letter.user.update(letter_sent_at: 1.day.ago, letter_verification_code: "123456")
      letter.verification_code = "123456"

      expect(letter.verified?).to eq(true)
      expect(letter.errors).to be_empty
    end
  end

end