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

    it "should not be valid without an address" do
      letter.address = {}
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

    it "should update address" do
      expect(user.address).to have_attributes({
        postal_code:   "28013",
        street:        "ALCALÁ",
        street_type:   "CALLE",
        number:        "1",
        number_type:   "NUM",
        letter:        "B",
        portal:        "1",
        stairway:      "4",
        floor:         "PB",
        door:          "DR",
        km:            "0",
        neighbourhood: "JUSTICIA",
        district:      "CENTRO"
      })
    end

  end

end