require 'rails_helper'

describe Organization do

  subject { create(:organization) }

  describe "verified?" do
    it "is false when verified_at? is blank" do
      expect(subject.verified?).to be false
    end
    it "is true when verified_at? exists" do
      subject.verified_at = Time.now
      expect(subject.verified?).to be true
    end
    it "is false when the organization was verified and then rejected" do
      subject.verified_at = Time.now
      subject.rejected_at = Time.now + 1
      expect(subject.verified?).to be false
    end
    it "is true when the organization was rejected and then verified" do
      subject.rejected_at = Time.now
      subject.verified_at = Time.now + 1
      expect(subject.verified?).to be true
    end
  end

  describe "rejected?" do
    it "is false when rejected_at? is blank" do
      expect(subject.rejected?).to be false
    end
    it "is true when rejected_at? exists" do
      subject.rejected_at = Time.now
      expect(subject.rejected?).to be true
    end
    it "is true when the organization was verified and then rejected" do
      subject.verified_at = Time.now
      subject.rejected_at = Time.now + 1
      expect(subject.rejected?).to be true
    end
    it "is false when the organization was rejected and then verified" do
      subject.rejected_at = Time.now
      subject.verified_at = Time.now + 1
      expect(subject.rejected?).to be false
    end
  end
end
