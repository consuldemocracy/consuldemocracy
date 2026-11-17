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

  describe "custom validations" do
    let(:signature) do
      build(:signature,
            document_number: "12345678Z",
            date_of_birth: "31/12/1980",
            postal_code: "28013")
    end

    before do
      Setting["feature.remote_census"] = true
      Setting["remote_census.request.date_of_birth"] = "some.value"
      Setting["remote_census.request.postal_code"] = "some.value"
    end

    it "is valid" do
      expect(signature).to be_valid
    end

    it "is not valid without a document number" do
      signature.document_number = nil
      expect(signature).not_to be_valid
    end

    it "is not valid without a date of birth" do
      signature.date_of_birth = nil

      expect(signature).not_to be_valid
    end

    it "is not valid without a postal_code" do
      signature.postal_code = nil

      expect(signature).not_to be_valid
    end
  end

  describe "document_number normalization" do
    it "removes non alphanumeric characters" do
      signature = Signature.new(document_number: "123-[;,9]")
      expect(signature.document_number).to eq("1239")
    end

    it "upcases letter in document number" do
      signature = Signature.new(document_number: "123a")
      expect(signature.document_number).to eq("123A")
    end

    it "deals gracefully with empty document numbers" do
      signature = Signature.new(document_number: "")
      expect(signature.document_number).to eq("")
    end
  end

  describe "#verify" do
    context "existing user" do
      let(:user) { create(:user, :level_two, document_number: "123A") }

      it "assigns vote to user on proposal" do
        signature = create(:signature, document_number: user.document_number)
        proposal = signature.signable

        signature.verify

        expect(user.voted_for?(proposal)).to be
      end

      it "assigns vote to user on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        signature = create(:signature, document_number: user.document_number,
                                       signature_sheet: signature_sheet)

        signature.verify

        expect(user.voted_for?(investment)).to be
      end

      it "does not assign vote to user multiple times" do
        signature = create(:signature, document_number: user.document_number)

        signature.verify
        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assigns vote to invalid user on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        user = create(:user, document_number: "123A")
        signature = create(:signature, document_number: user.document_number,
                                       signature_sheet: signature_sheet)

        signature.verify

        expect(user.voted_for?(investment)).not_to be
        expect(Vote.count).to eq(0)
      end

      it "does not assign vote to user multiple times on budget investment" do
        investment = create(:budget_investment)
        signature_sheet = create(:signature_sheet, signable: investment)
        signature = create(:signature, document_number: user.document_number,
                                       signature_sheet: signature_sheet)

        signature.verify
        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assign vote to user if already voted" do
        proposal = create(:proposal, voters: [user])
        signature_sheet = create(:signature_sheet, signable: proposal)
        signature = create(:signature, signature_sheet: signature_sheet,
                                       document_number: user.document_number)

        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "does not assign vote to user if already voted on budget investment" do
        investment = create(:budget_investment, voters: [user])

        signature_sheet = create(:signature_sheet, signable: investment)
        signature = create(:signature, document_number: user.document_number,
                                       signature_sheet: signature_sheet)

        expect(Vote.count).to eq(1)

        signature.verify

        expect(Vote.count).to eq(1)
      end

      it "marks the vote as coming from a signature" do
        signature = create(:signature, document_number: user.document_number)

        signature.verify

        expect(Vote.last.signature).to eq(signature)
      end

      it "does not update the signature when assigning the vote raises an exception" do
        signature = create(:signature, document_number: user.document_number)
        allow(signature).to receive(:assign_vote_to_user).and_raise "Not assigned!"

        expect { signature.verify }.to raise_error "Not assigned!"

        expect(signature.reload.user).to be nil
        expect(signature).not_to be_verified
      end

      it "does not create two votes when calling the method twice at the same time", :race_condition do
        signature = create(:signature, document_number: user.document_number)

        2.times.map do
          Thread.new { signature.verify }
        end.each(&:join)

        votes = Vote.where(voter: user, votable: signature.signable)
        expect(votes.count).to eq 1
        expect(votes.first.signature).to eq(signature)
      end

      it "does not create two votes when voting on different headings at the same time", :race_condition do
        investment = create(:budget_investment)
        investment2 = create(:budget_investment, heading: create(:budget_heading, group: investment.group))
        signature = create(:signature, signature_sheet: create(:signature_sheet, signable: investment),
                                       document_number: user.document_number)
        signature2 = create(:signature, signature_sheet: create(:signature_sheet, signable: investment2),
                                        document_number: user.document_number)

        [
          Thread.new { signature.verify },
          Thread.new { signature2.verify }
        ].each(&:join)

        votes = Vote.where(voter: user, votable: [investment, investment2])
        expect(votes.count).to eq 1
        expect([signature, signature2]).to include votes.first.signature
      end

      it "does not create two users when signing twice at the same time", :race_condition do
        signature = create(:signature, document_number: "12345678Z")
        signature2 = create(:signature, document_number: "12345678Z")

        [
          Thread.new { signature.verify },
          Thread.new { signature2.verify }
        ].each(&:join)

        expect(User.by_document("1", "12345678Z").count).to eq 1
      end
    end

    context "inexistent user" do
      let(:signature) { create(:signature, document_number: "12345678Z") }

      it "creates a user with that document number" do
        create(:geozone, census_code: "01")

        signature.verify

        user = User.last
        expect(user.document_number).to eq "12345678Z"
        expect(user.document_type).to eq "1"
        expect(user.created_from_signature).to be true
        expect(user.verified_at).to be
        expect(user.erased_at).to be
        expect(user.geozone).to be
        expect(user.gender).to be
        expect(user.date_of_birth).to be
      end

      it "assign the vote to newly created user" do
        proposal = signature.signable

        signature.verify

        user = signature.user
        expect(user.voted_for?(proposal)).to be
      end

      it "marks the vote as coming from a signature" do
        signature.verify

        expect(Vote.last.signature).to eq(signature)
      end

      it "does not update the signature when assigning the vote raises an exception" do
        allow(signature).to receive(:assign_vote_to_user).and_raise "Not assigned!"

        expect { signature.verify }.to raise_error "Not assigned!"

        expect(signature.reload.user).to be nil
        expect(signature).not_to be_verified
      end

      it "generates a complex password for the user" do
        stub_secrets(security: { password_complexity: true })

        signature.verify

        expect(signature.user).to be_valid
      end
    end

    context "unregistered user in the local census" do
      before { create(:local_census_record, document_number: "99999999R", document_type: "3") }

      it "creates a user with the document type found in the census" do
        signature = create(:signature, document_number: "99999999R")

        signature.verify
        user = User.last

        expect(user.document_number).to eq "99999999R"
        expect(user.document_type).to eq "3"
        expect(user.created_from_signature).to be true
      end
    end

    context "hidden user" do
      it "creates a vote without restoring the account" do
        user = create(:user, :level_two, :hidden, document_number: "12345678Z")
        signature = create(:signature, document_number: user.document_number)

        signature.verify

        expect(signature.reload).to be_verified
        expect(signature.user_id).to eq user.id
        expect(Vote.where(votable: signature.signable, voter: user).count).to eq 1
        expect(User.ids).not_to include user.id
        expect(User.only_hidden).to eq [user]
      end

      it "does not create a second vote when the user has already voted" do
        user = create(:user, :level_two, :hidden, document_number: "12345678Z")
        signature = create(:signature, document_number: user.document_number)
        create(:vote, voter: user, votable: signature.signable)

        signature.verify

        expect(signature.reload).to be_verified
        expect(signature.user_id).to eq user.id
        expect(Vote.where(votable: signature.signable, voter: user).count).to eq 1
        expect(User.ids).not_to include user.id
        expect(User.only_hidden).to eq [user]
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

    describe "document in census throught CustomCensusApi" do
      it "calls assign_vote_to_user", :remote_census do
        signature = create(:signature, document_number: "12345678Z",
                                       date_of_birth: "31/12/1980",
                                       postal_code: "28013")

        mock_valid_remote_census_response

        expect_any_instance_of(Signature).to receive(:assign_vote_to_user).exactly(1).times

        signature.verify
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
