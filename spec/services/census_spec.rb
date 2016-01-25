require 'rails_helper'

describe Census, vcr: true do
  let(:client) { Census.client }
  it "returns valid" do
    census = Census.new(
      date_of_birth: Date.civil(1987, 9, 17),
      postal_code: "08001",
      document_number: "12345678A",
      document_type: :nie
    )

    expect(census).to be_valid
  end

  context "when it's invalid" do
    it "returns invalid on wrong date" do
      census = Census.new(
        date_of_birth: Date.civil(1987, 9, 18),
        postal_code: "08001",
        document_number: "12345678A",
        document_type: :dni
      )

      expect(census).to_not be_valid
    end

    it "returns invalid on wrong postal code" do
      census = Census.new(
        date_of_birth: Date.civil(1987, 9, 17),
        postal_code: "08002",
        document_number: "12345678A",
        document_type: :dni
      )

      expect(census).to_not be_valid
    end

    it "returns invalid on wrong dni" do
      census = Census.new(
        date_of_birth: Date.civil(1987, 9, 17),
        postal_code: "0800",
        document_number: "12345678B",
        document_type: :dni
      )

      expect(census).to_not be_valid
    end
  end
end
