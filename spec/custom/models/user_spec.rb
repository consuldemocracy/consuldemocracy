require 'rails_helper'

describe User do

  # Tests fixes =============================================

  describe "#age" do
    it "is the rounded integer age based on the date_of_birth" do
      user = create(:user, date_of_birth: Date.current.ago(User.minimum_required_age.years).to_date)
      expect(user.age).to eq(16)
    end
  end

  describe "#erase" do
    it "erases user information and marks him as erased" do
      user = create(:user,
                     username: "manolo",
                     email: "a@a.com",
                     unconfirmed_email: "a@a.com",
                     date_of_birth: Date.current.ago(User.minimum_required_age.years).to_date,
                     phone_number: "5678",
                     confirmed_phone: "5678",
                     unconfirmed_phone: "5678",
                     encrypted_password: "foobar",
                     confirmation_token: "token1",
                     reset_password_token: "token2",
                     email_verification_token: "token3")

      user.erase('a test')
      user.reload

      expect(user.erase_reason).to eq('a test')
      expect(user.erased_at).to    be

      expect(user.username).to be_nil
      expect(user.email).to be_nil
      expect(user.unconfirmed_email).to be_nil
      expect(user.phone_number).to be_nil
      expect(user.confirmed_phone).to be_nil
      expect(user.unconfirmed_phone).to be_nil
      expect(user.encrypted_password).to be_empty
      expect(user.confirmation_token).to be_nil
      expect(user.reset_password_token).to be_nil
      expect(user.email_verification_token).to be_nil
    end
  end

  # New tests =============================================

  describe "#age_in_allowed_range" do

    subject { build(:user) }
    let!(:max_date_of_birth) { Date.current.ago(User.maximum_required_age.years).to_date }
    let(:min_date_of_birth) { Date.current.ago(User.minimum_required_age.years).to_date }

    it "is valid if young enough" do
      subject.date_of_birth = max_date_of_birth + 1.day
      expect(subject).to be_valid
    end

    it "is valid if old enough" do
      subject.date_of_birth = min_date_of_birth
      expect(subject).to be_valid
    end

    it "is not valid if too young" do
      subject.date_of_birth = min_date_of_birth + 1.day
      expect(subject).not_to be_valid
    end

    it "is not valid if too old" do
      subject.date_of_birth = max_date_of_birth
      expect(subject).not_to be_valid
    end
  end

  describe "#postal_code_in_aude" do

    subject { build(:user) }

    it "is valid if in Carcassonne" do
      subject.postal_code = '11000'
      expect(subject).to be_valid
    end

    it "is not valid if in Epinal" do
      subject.postal_code = '88000'
      expect(subject).not_to be_valid
    end

    it "is not valid if incorrect postal code" do
      subject.postal_code = '11abc'
      expect(subject).not_to be_valid
    end
  end


end
