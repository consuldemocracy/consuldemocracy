require "rails_helper"

describe DocumentNumberNormalizer do
  it "removes every character except numbers and letters, and upcases" do
    expect(DocumentNumberNormalizer.call(" 12.345.678 - b")).to eq "12345678B"
  end

  it "leaves an already normalized document number unchanged" do
    expect(DocumentNumberNormalizer.call("X1234567Z")).to eq "X1234567Z"
  end

  it "normalizes the attribute when the attribute is declared before normalizes" do
    model = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveModel::Attributes::Normalization

      attribute :document_number, :string
      normalizes :document_number, with: DocumentNumberNormalizer
    end

    expect(model.new(document_number: "x1234567z").document_number).to eq "X1234567Z"
    expect(model.new(document_number: nil).document_number).to be nil
  end
end
