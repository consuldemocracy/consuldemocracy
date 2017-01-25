require 'rails_helper'

describe Poll::Answer do

  describe "validations" do
    it "validates that the answers are included in the Poll::Question's list" do
      q = create(:poll_question, valid_answers: 'One, Two, Three')
      expect(build(:poll_answer, question: q, answer: 'One')).to be_valid
      expect(build(:poll_answer, question: q, answer: 'Two')).to be_valid
      expect(build(:poll_answer, question: q, answer: 'Three')).to be_valid

      expect(build(:poll_answer, question: q, answer: 'Four')).to_not be_valid
    end
  end

end
