require "rails_helper"

describe Signature do

  let(:signature) { build(:signature) }

  describe "validations" do

    it "is valid" do
      expect(signature).to be_valid
    end

    it "is not valid without a document number" do
      signature.document_number = nil
      expect(signature).not_to be_valid

      signature.document_number = ""
      expect(signature).not_to be_valid

      signature.document_number = " "
      expect(signature).not_to be_valid
    end

    it "is not valid without an associated signature sheet" do
      signature.signature_sheet = nil
      expect(signature).not_to be_valid
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

  describe "#verify" do

    describe "existing user" do

      it "assigns vote to user on proposal" do
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number)
        proposal = signature.signable

        signature.verify

        expect(user.voted_for?(proposal)).to be
      end

      it "assigns vote to user on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number, signature_sheet: signature_sheet)

        signature.verify

        expect(user.voted_for?(investment)).to be
      end

      it "does not assign vote to user multiple times" do
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number)

        signature.verify
        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assigns vote to invalid user on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        user = create(:user, document_number: "123A")
        signature = create(:signature, document_number: user.document_number, signature_sheet: signature_sheet)

        signature.verify

        expect(user.voted_for?(investment)).not_to be
        expect(Vote.count).to eq(0)
      end

      it "does not assign vote to user multiple times on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        user = create(:user, :level_two, document_number: "123A")
        signature = create(:signature, document_number: user.document_number, signature_sheet: signature_sheet)

        signature.verify
        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assign vote to user if already voted" do
        proposal = create(:proposal)
        user = create(:user, :level_two, document_number: "123A")
        vote = create(:vote, votable: proposal, voter: user)
        signature_sheet = create(:signature_sheet, signable: proposal)
        signature = create(:signature, signature_sheet: signature_sheet, document_number: user.document_number)

        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assign vote to user if already voted on budget investment" do
        investment = create(:budget_investment)
        user = create(:user, :level_two, document_number: "123A")
        vote = create(:vote, votable: investment, voter: user)

        signature_sheet = create(:signature_sheet, signable: investment)
        signature = create(:signature, document_number: user.document_number, signature_sheet: signature_sheet)

        expect(Vote.count).to eq(1)

        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "marks the vote as coming from a signature" do
        signature = create(:signature, document_number: "12345678Z")

        signature.verify

        expect(Vote.last.signature).to eq(signature)
      end

    end

    describe "inexistent user" do

      it "creates a user with that document number" do
        create(:geozone, census_code: "01")
        signature = create(:signature, document_number: "12345678Z")
        proposal = signature.signable

        signature.verify

        user = User.last
        expect(user.document_number).to eq("12345678Z")
        expect(user.created_from_signature).to eq(true)
        expect(user.verified_at).to be
        expect(user.erased_at).to be
        expect(user.geozone).to be
        expect(user.gender).to be
        expect(user.date_of_birth).to be
      end

      it "assign the vote to newly created user" do
        signature = create(:signature, document_number: "12345678Z")
        proposal = signature.signable

        signature.verify

        user = signature.user
        expect(user.voted_for?(proposal)).to be
      end

      it "assigns signature to vote" do
        signature = create(:signature, document_number: "12345678Z")

        signature.verify

        expect(Vote.last.signature).to eq(signature)
      end
    end

    describe "document in census" do

      it "calls assign_vote_to_user" do
        signature = create(:signature, document_number: "12345678Z")

        allow(signature).to receive(:assign_vote_to_user)
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

      it "does not call assign_vote_to_user" do
        signature = create(:signature, document_number: "123A")

        expect(signature).not_to receive(:assign_vote_to_user)
        signature.verify
      end

      it "maintains signature as not verified" do
        signature = create(:signature, document_number: "123A")

        signature.verify
        expect(signature).not_to be_verified
      end
    end

  end

end
