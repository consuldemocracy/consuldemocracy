require 'rails_helper'

RSpec.describe Enquiry::Answer, type: :model do
  describe "validations" do
    it "validates that the answers are included in the Enquiry's list" do
      e = create(:enquiry, valid_answers: 'One, Two, Three')
      expect(build(:enquiry_answer, enquiry: e, answer: 'One')).to be_valid
      expect(build(:enquiry_answer, enquiry: e, answer: 'Two')).to be_valid
      expect(build(:enquiry_answer, enquiry: e, answer: 'Three')).to be_valid

      expect(build(:enquiry_answer, enquiry: e, answer: 'Four')).to_not be_valid
    end
  end
end
