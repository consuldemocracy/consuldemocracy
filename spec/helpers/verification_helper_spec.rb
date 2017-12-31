require 'rails_helper'

describe VerificationHelper do

  describe "#mask_phone" do
    it "should mask a phone" do
      expect(mask_phone("612345678")).to eq("******678")
    end
  end

  describe "#mask_email" do
    it "should mask a long email address" do
      expect(mask_email("isabel@example.com")).to eq("isa***@example.com")
      expect(mask_email("antonio.perez@example.com")).to eq("ant**********@example.com")
    end

    it "should mask a short email address" do
      expect(mask_email("an@example.com")).to eq("an@example.com")
      expect(mask_email("ana@example.com")).to eq("ana@example.com")
      expect(mask_email("aina@example.com")).to eq("ain*@example.com")
    end
  end

end