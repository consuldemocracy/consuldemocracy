require 'rails_helper'

describe Poll::Answer do

  describe "validations" do

    let(:answer) { build(:poll_answer) }

    it "is valid" do
      expect(answer).to be_valid
    end

    it "is not valid wihout a question" do
      answer.question = nil
      expect(answer).to_not be_valid
    end

    it "is not valid without an author" do
      answer.author = nil
      expect(answer).to_not be_valid
    end

    it "is not valid without an answer" do
      answer.answer = nil
      expect(answer).to_not be_valid
    end

    it "is valid for answers included in the Poll::Question's question_answers list" do
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

end
