require 'rails_helper'

describe Poll::Answer do

  describe "validations" do

    let(:answer) { build(:poll_answer) }

    it "should be valid" do
      expect(answer).to be_valid
    end

    it "should not be valid wihout a question" do
      answer.question = nil
      expect(answer).to_not be_valid
    end

    it "should not be valid without an author" do
      answer.author = nil
      expect(answer).to_not be_valid
    end

    it "should not be valid without an answer" do
      answer.answer = nil
      expect(answer).to_not be_valid
    end

    it "should be valid for answers included in the Poll::Question's question_answers list" do
      question = create(:poll_question)
      create(:poll_question_answer, title: 'One', question: question)
      create(:poll_question_answer, title: 'Two', question: question)
      create(:poll_question_answer, title: 'Three', question: question)

      expect(build(:poll_answer, question: question, answer: 'One')).to be_valid
      expect(build(:poll_answer, question: question, answer: 'Two')).to be_valid
      expect(build(:poll_answer, question: question, answer: 'Three')).to be_valid

      expect(build(:poll_answer, question: question, answer: 'Four')).to_not be_valid
    end
  end

  describe "#record_voter_participation" do

    let(:author) { create(:user, :level_two) }
    let(:poll) { create(:poll) }
    let(:question) { create(:poll_question, :with_answers, poll: poll) }

    it "creates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      expect(answer.poll.voters).to be_blank

      answer.record_voter_participation('token')
      expect(poll.reload.voters.size).to eq(1)
      voter = poll.voters.first

      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
      expect(voter.officer_id).to eq(nil)
    end

    it "updates a poll_voter with user and poll data" do
      answer = create(:poll_answer, question: question, author: author, answer: "Yes")
      answer.record_voter_participation('token')

      expect(poll.reload.voters.size).to eq(1)

      answer = create(:poll_answer, question: question, author: author, answer: "No")
      answer.record_voter_participation('token')

      expect(poll.reload.voters.size).to eq(1)

      voter = poll.voters.first
      expect(voter.document_number).to eq(answer.author.document_number)
      expect(voter.poll_id).to eq(answer.poll.id)
    end
  end

end
