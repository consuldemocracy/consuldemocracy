require 'rails_helper'

describe SignatureSheet do

  describe "validations" do
    it "should be valid"
    it "should not be valid without a valid signable"
    it "should not be valid without document numbers"
    it "should not be valid without an author"
  end

  describe "name" do
    it "returns name for proposal signature sheets"
    it "returns name for spending proposal signature sheets"
  end

  describe "verify_signatures" do
    it "marks signature sheet as processed after verifing all document numbers"
  end

  describe "invalid_signatures" do
    it "returns invalid signatures"
    it "does not return valid signatures"
  end

  describe "parsed_document_numbers" do
    it "returns an array after spliting document numbers by newlines"
  end

end