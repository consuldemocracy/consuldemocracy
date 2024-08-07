require "rails_helper"

describe DocumentParser do
  before do
    dummy_class = Class.new do
      include DocumentParser
    end

    stub_const("DummyClass", dummy_class)
  end

  let(:dummy) { DummyClass.new }

  describe "#get_document_number_variants" do
    it "returns no variants when document_number is not defined" do
      expect(dummy.get_document_number_variants("1", "")).to be_empty
    end

    it "trims and cleans up entry" do
      expect(dummy.get_document_number_variants(2, "  1 2@ 34")).to eq(["1234"])
    end

    it "returns only one try for passports & residence cards" do
      expect(dummy.get_document_number_variants(2, "1234")).to eq(["1234"])
      expect(dummy.get_document_number_variants(3, "1234")).to eq(["1234"])
    end

    it "takes only the last 8 digits for dnis and resicence cards" do
      expect(dummy.get_document_number_variants(1, "543212345678")).to eq(["12345678"])
    end

    it "tries all the dni variants padding with zeroes" do
      expect(dummy.get_document_number_variants(1, "0123456"))
        .to eq(["123456", "0123456", "00123456"])

      expect(dummy.get_document_number_variants(1, "00123456"))
        .to eq(["123456", "0123456", "00123456"])
    end

    it "adds upper and lowercase letter when the letter is present" do
      expect(dummy.get_document_number_variants(1, "1234567A"))
        .to eq(%w[1234567 01234567 1234567a 1234567A 01234567a 01234567A])
    end
  end
end
