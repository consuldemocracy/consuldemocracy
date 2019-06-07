require "rails_helper"

describe Organization do

  subject { create(:organization) }

  describe "verified?" do
    it "is false when verified_at? is blank" do
      expect(subject.verified?).to be false
    end
    it "is true when verified_at? exists" do
      subject.verified_at = Time.current
      expect(subject.verified?).to be true
    end
    it "is false when the organization was verified and then rejected" do
      subject.verified_at = Time.current
      subject.rejected_at = Time.current + 1
      expect(subject.verified?).to be false
    end
    it "is true when the organization was rejected and then verified" do
      subject.rejected_at = Time.current
      subject.verified_at = Time.current + 1
      expect(subject.verified?).to be true
    end
  end

  describe "rejected?" do
    it "is false when rejected_at? is blank" do
      expect(subject.rejected?).to be false
    end
    it "is true when rejected_at? exists" do
      subject.rejected_at = Time.current
      expect(subject.rejected?).to be true
    end
    it "is true when the organization was verified and then rejected" do
      subject.verified_at = Time.current
      subject.rejected_at = Time.current + 1
      expect(subject.rejected?).to be true
    end
    it "is false when the organization was rejected and then verified" do
      subject.rejected_at = Time.current
      subject.verified_at = Time.current + 1
      expect(subject.rejected?).to be false
    end
  end

  describe "self.search" do
    let!(:organization) { create(:organization, name: "Watershed", user: create(:user, phone_number: "333")) }

    it "returns no results if search term is empty" do
      expect(described_class.search(" ").size).to eq(0)
    end

    it "finds fuzzily by name" do
      expect(described_class.search("Greenpeace").size).to eq 0
      search = described_class.search("Tershe")
      expect(search.size).to eq 1
      expect(search.first).to eq organization
    end

    scenario "finds by users email" do
      search = described_class.search(organization.user.email)
      expect(search.size).to eq 1
      expect(search.first).to eq organization
    end

    scenario "finds by users phone number" do
      search = described_class.search(organization.user.phone_number)
      expect(search.size).to eq 1
      expect(search.first).to eq organization
    end
  end
end
