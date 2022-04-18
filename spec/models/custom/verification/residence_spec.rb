require "rails_helper"

describe Verification::Residence do
  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "verification" do
    describe "postal code" do
      it "is valid with postal code 38400" do
        residence.postal_code =  "38400"
        residence.valid?
        expect(residence.errors[:postal_code]).to be_empty
      end

      it "is not valid with other postal codes" do
        residence.postal_code = "12345"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)

        residence.postal_code = "13280"
        residence.valid?
        expect(residence.errors[:postal_code]).to eq ["In order to be verified, you must be registered."]
      end
    end
  end
end
