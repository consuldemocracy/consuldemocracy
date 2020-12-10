require "rails_helper"

describe CustomHelper do
  describe "#raw_phone" do
    it "removes non-needed characters" do
      phone = raw_phone("(+34) 91-123 45 67")

      expect(phone).to eq "+34911234567"
    end

    it "adds a + if it isn't there" do
      phone = raw_phone("34 91 123 45 67")

      expect(phone).to eq "+34911234567"
    end

    it "returns an empty string when nil is passed" do
      expect(raw_phone(nil)).to eq ""
    end
  end

  describe "#format_phone" do
    it "generates parenthesis and spaces where appropriate" do
      expect(format_phone("+34911234567")).to eq "(+34) 911 234 567"
    end

    it "returns an empty string when nil is passed" do
      expect(format_phone(nil)).to eq ""
    end
  end
end
