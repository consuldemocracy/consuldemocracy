require "rails_helper"

describe Verification::Management::Email do

  describe "#user" do
    subject { described_class.new(document_type: "1", document_number: "1234", email: "inexisting@gmail.com") }

    it "returns nil/false when the user does not exist" do
      expect(subject.user).to be_nil
      expect(subject.user?).not_to be
    end
  end

  describe "validations" do
    it "is not valid if the user does not exist" do
      expect(described_class.new(document_type: "1", document_number: "1234", email: "inexisting@gmail.com")).not_to be_valid
    end

    it "is not valid if the user is already level 3" do
      user = create(:user, :level_three)
      expect(described_class.new(document_type: "1", document_number: "1234", email: user.email)).not_to be_valid
    end

    it "is not valid if the user already has a different document number" do
      user = create(:user, document_number: "1234", document_type: "1")
      expect(described_class.new(document_type: "1", document_number: "5678", email: user.email)).not_to be_valid
    end
  end

  describe "#save" do
    it "does nothing if not valid" do
      expect(described_class.new(document_type: "1", document_number: "1234", email: "inexisting@gmail.com").save).to eq(false)
    end

    it "updates the user and sends an email" do
      user = create(:user)
      validation = described_class.new(document_type: "1", document_number: "1234", email: user.email)

      mail = double(:mail)

      allow(validation).to receive(:user).and_return user
      allow(mail).to receive(:deliver_later)
      allow(Devise.token_generator).to receive(:generate).with(User, :email_verification_token).and_return(["1", "2"])
      allow(Mailer).to receive(:email_verification).with(user, user.email, "2", "1", "1234").and_return(mail)

      validation.save

      expect(user.reload).to be_level_two_verified
      expect(user.document_type).to eq("1")
      expect(user.document_number).to eq("1234")
    end
  end
end
