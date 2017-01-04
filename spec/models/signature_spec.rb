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

      signature.document_number = ""
      expect(signature).to_not be_valid

      signature.document_number = " "
      expect(signature).to_not be_valid
    end

    it "should not be valid without an associated signature sheet" do
      signature.signature_sheet = nil
      expect(signature).to_not be_valid
    end

  end

  describe "#clean_document_number" do
    it "removes non alphanumeric characters" do
      signature = create(:signature, document_number: "123-[;,9]")
      expect(signature.document_number).to eq("1239")
    end

    it "upcases letter in document number" do
      signature = create(:signature, document_number: "123a")
      expect(signature.document_number).to eq("123A")
    end

    it "deals gracefully with empty document numbers" do
      signature = build(:signature, document_number: "")
      signature.clean_document_number
      expect(signature.document_number).to eq("")
    end
  end

  describe "#verified?" do

    it "returns true if user exists" do
      user = create(:user, :level_two, document_number: "123A")
      signature = create(:signature, document_number: user.document_number)

      expect(signature.verified?).to eq(true)
    end

    it "returns true if document number in census" do
      signature = create(:signature, document_number: "12345678Z")

      expect(signature.verified?).to eq(true)
    end

    it "returns false if user does not exist and not in census" do
      signature = create(:signature, document_number: "123A")

      expect(signature.verified?).to eq(false)
    end

  end

  describe "#assign_vote" do

    describe "existing user" do

      it "assigns vote to user" do
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number)
        proposal = signature.signable

        signature.assign_vote

        expect(user.voted_for?(proposal)).to be
      end

      it "does not assign vote to user multiple times" do
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number)

        signature.assign_vote
        signature.assign_vote

        expect(Vote.count).to eq(1)
      end

      it "does not assign vote to user if already voted" do
        proposal = create(:proposal)
        user = create(:user, :level_two, document_number: "123A")
        vote = create(:vote, votable: proposal, voter: user)
        signature_sheet = create(:signature_sheet, signable: proposal)
        signature = create(:signature, signature_sheet: signature_sheet, document_number: user.document_number)

        signature.assign_vote

        expect(Vote.count).to eq(1)
      end

      it "marks the vote as coming from a signature" do
        signature = create(:signature, document_number: "12345678Z")

        signature.assign_vote

        expect(Vote.last.signature).to eq(signature)
      end

    end

    describe "inexistent user" do

      it "creates a user with that document number" do
        signature = create(:signature, document_number: "12345678Z")
        proposal = signature.signable

        signature.assign_vote

        user = User.last
        expect(user.document_number).to eq("12345678Z")
        expect(user.created_from_signature).to eq(true)
        expect(user.verified_at).to be
        expect(user.erased_at).to be
      end

      it "assign the vote to newly created user" do
        signature = create(:signature, document_number: "12345678Z")
        proposal = signature.signable

        signature.assign_vote

        user = signature.user
        expect(user.voted_for?(proposal)).to be
      end

      it "assigns signature to vote" do
        signature = create(:signature, document_number: "12345678Z")

        signature.assign_vote

        expect(Vote.last.signature).to eq(signature)
      end
    end

  end

  describe "#verify" do

    describe "document in census" do

      it "calls assign_vote" do
        signature = create(:signature, document_number: "12345678Z")

        expect(signature).to receive(:assign_vote)
        signature.verify
      end

      it "sets signature as verified" do
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number)

        signature.verify

        expect(signature).to be_verified
      end

    end

    describe "document not in census" do

      it "does not call assign_vote" do
        signature = create(:signature, document_number: "123A")

        expect(signature).to_not receive(:assign_vote)
        signature.verify
      end

      it "maintains signature as not verified" do
        signature = create(:signature, document_number: "123A")

        signature.verify
        expect(signature).to_not be_verified
      end
    end

  end

end