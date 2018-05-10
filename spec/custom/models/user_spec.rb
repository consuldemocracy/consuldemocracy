require 'rails_helper'

describe User do

  describe "#age" do
    it "is the rounded integer age based on the date_of_birth" do
      user = create(:user, date_of_birth: 18.years.ago)
      expect(user.age).to eq(18)
    end
  end

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
