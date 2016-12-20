require 'rails_helper'

describe Signature do

  let(:signature) { build(:signature) }

  describe "validations" do
    it "should be valid" do
      expect(signature).to be_valid
    end

    it "should not be valid without a document number" do
      signature.document_number = nil
      expect(signature).to_not be_valid
    end

    it "should not be valid without an associated signature sheet" do
      signature.signature_sheet = nil
      expect(signature).to_not be_valid
    end
  end

  describe "#in_census" do
    it "checks for all document_types" do
      ####
    end
  end

  describe "#verify" do

    describe "valid", :focus do
      it "asigns vote to user" do
        proposal = create(:proposal)
        user = create(:user, document_number: "123A")
        signature_sheet = create(:signature_sheet, signable: proposal)
        signature = create(:signature, signature_sheet: signature_sheet, document_number: "123A")

        signature.verify
        expect(user.voted_for?(proposal)).to be
      end

      it "sets status to verified" do

      end

    end

    describe "invalid" do
      it "sets status to error"
      it "does not asign any votes"
    end

  end

  describe "#verified?" do
    it "returns true if user exists" do

    end

    it "returns true if document number in census"
    it "returns false if user does not exist and not in census"
  end

  describe "#assign_vote" do

    describe "existing user" do
      it "assigns vote to user"
      it "does not assign vote to user if already voted"
      it "marks the vote as coming from a signature"
    end

    describe "inexistent user" do
      it "creates a user with that document number"
      it "assign the vote to newly created user"
      it "marks the vote as coming from a signature"
    end

  end

end