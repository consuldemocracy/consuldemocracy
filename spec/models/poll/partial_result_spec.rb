require 'rails_helper'

describe Poll::PartialResult, type: :model do

  describe "validations" do
    it "validates that the answers are included in the Enquiry's list" do
      q = create(:poll_question, valid_answers: 'One, Two, Three')
      expect(build(:poll_partial_result, question: q, answer: 'One')).to be_valid
      expect(build(:poll_partial_result, question: q, answer: 'Two')).to be_valid
      expect(build(:poll_partial_result, question: q, answer: 'Three')).to be_valid

      expect(build(:poll_partial_result, question: q, answer: 'Four')).to_not be_valid
    end
  end

end
