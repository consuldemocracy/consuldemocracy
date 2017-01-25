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

  describe "#record_voter_participation" do
    it "creates a poll_voter with user and poll data" do
      answer = create(:poll_answer)
      expect(answer.voter).to be_nil

      answer.record_voter_participation
      voter = answer.reload.voter

      expect(voter.answer).to eq(answer)
      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
    end
  end

end
