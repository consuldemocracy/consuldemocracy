require 'rails_helper'

describe Census do
  let(:client) { Census.client }

  it "returns valid", :vcr do
    census = Census.new(
      document_number: "123VALID",
      document_type: :nie
    )

    expect(census).to be_valid
  end

  it "returns invalid", :vcr do
    census = Census.new(
      document_number: "12345678X",
      document_type: :dni
    )

    expect(census).to_not be_valid
  end
end
