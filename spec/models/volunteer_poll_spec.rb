require 'rails_helper'

describe VolunteerPoll do

  let(:volunteer) { build(:volunteer_poll) }

  describe "validations" do
    it "should be valid" do
      expect(volunteer).to be_valid
    end

    it "should not be valid with an email" do
      volunteer.email = nil
      expect(volunteer).to_not be_valid
    end

    it "should not be valid with a first name" do
      volunteer.first_name = nil
      expect(volunteer).to_not be_valid
    end

    it "should not be valid with a last name" do
      volunteer.last_name = nil
      expect(volunteer).to_not be_valid
    end

    it "should not be valid with a document number" do
      volunteer.document_number = nil
      expect(volunteer).to_not be_valid
    end

    it "should not be valid with a phone" do
      volunteer.phone = nil
      expect(volunteer).to_not be_valid
    end
  end

end