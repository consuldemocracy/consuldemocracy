require "rails_helper"

describe Verification::Letter do

  let(:user) { create(:user) }

  describe "validations" do

    let(:letter) { build(:verification_letter) }

    it "is valid" do
      expect(letter).to be_valid
    end

    it "is not valid without a user" do
      letter.user = nil
      expect(letter).not_to be_valid
    end

  end

  describe "save" do

    it "updates letter_requested" do
      letter = build(:verification_letter)
      letter.save
      expect(letter.user.letter_requested_at).to be
    end

  end

  describe "#verify" do

    let(:letter) { build(:verification_letter, verify: true) }

    it "incorrect code" do
      letter.user.update(letter_verification_code: "123456")
      letter.verification_code = "5555"

      expect(letter.valid?).to eq(false)
      expect(letter.errors[:verification_code].first).to eq("Verification code incorrect")
    end

    it "correct code" do
      letter.user.update(letter_verification_code: "123456")
      letter.verification_code = "123456"

      expect(letter.valid?).to eq(true)
      expect(letter.errors).to be_empty
    end

    it "ignores trailing zeros" do
      letter.user.update(letter_verification_code: "003456")
      letter.verification_code = "3456"

      expect(letter.valid?).to eq(true)
      expect(letter.errors).to be_empty
    end
  end

end
