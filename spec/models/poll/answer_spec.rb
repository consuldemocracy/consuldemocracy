require "rails_helper"

describe Poll::Answer do
  describe "validations" do
    let(:answer) { build(:poll_answer) }

    it "is valid" do
      expect(answer).to be_valid
    end

    it "is not valid wihout a question" do
      answer.question = nil
      expect(answer).not_to be_valid
    end

    it "is not valid without an author" do
      answer.author = nil
      expect(answer).not_to be_valid
    end

    it "is not valid without an author when multiple answers are allowed" do
      answer.author = nil
      answer.question = create(:poll_question_multiple)

      expect(answer).not_to be_valid
    end

    it "is not valid without an answer when question is open-ended" do
      answer.question = create(:poll_question_open)
      answer.option = nil
      answer.answer = nil

      expect(answer).not_to be_valid
    end

    it "is valid without answer text when an option is present" do
      expect(answer).to be_valid
      expect(answer.answer).to be nil
    end

    it "is not valid when there are two identical answers" do
      author = create(:user)
      question = create(:poll_question_multiple, :abc)
      option = question.question_options.first

      create(:poll_answer, author: author, question: question, option: option, answer: "Answer A")

      answer = build(:poll_answer, author: author, question: question, option: option, answer: "Answer A")

      expect(answer).not_to be_valid
      expect { answer.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
    end

    it "is not valid when there are two answers with the same option and different answer" do
      author = create(:user)
      question = create(:poll_question_multiple, :abc)
      option = question.question_options.first

      create(:poll_answer, author: author, question: question, option: option, answer: "Answer A")

      answer = build(:poll_answer, author: author, question: question, option: option, answer: "Answer B")

      expect(answer).not_to be_valid
      expect { answer.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
    end

    it "is valid when there are two identical answers and the option is nil" do
      author = create(:user)
      question = create(:poll_question_multiple, :abc)

      create(:poll_answer, author: author, question: question, option: nil, answer: "Answer A")

      answer = build(:poll_answer, author: author, question: question, option: nil, answer: "Answer A")

      expect(answer).to be_valid
      expect { answer.save }.not_to raise_error
    end

    it "accepts legacy text in option answers" do
      question = create(:poll_question)
      option = create(:poll_question_option, title: "One", question: question)

      expect(build(:poll_answer, option: option, answer: "legacy snapshot")).to be_valid
    end
  end
end
