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

    it "is not valid without an answer" do
      answer.answer = nil
      expect(answer).not_to be_valid
    end

    it "is not valid if there's already an answer to that question" do
      author = create(:user)
      question = create(:poll_question, :yes_no)

      create(:poll_answer, author: author, question: question)

      answer = build(:poll_answer, author: author, question: question)

      expect(answer).not_to be_valid
    end

    it "is not valid when user already reached multiple answers question max votes" do
      author = create(:user)
      question = create(:poll_question_multiple, :abc, max_votes: 2)
      create(:poll_answer, author: author, question: question, answer: "Answer A")
      create(:poll_answer, author: author, question: question, answer: "Answer B")
      answer = build(:poll_answer, author: author, question: question, answer: "Answer C")

      expect(answer).not_to be_valid
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

    it "is valid for answers included in the Poll::Question's question_options list" do
      question = create(:poll_question)
      create(:poll_question_option, title: "One", question: question)
      create(:poll_question_option, title: "Two", question: question)
      create(:poll_question_option, title: "Three", question: question)

      expect(build(:poll_answer, question: question, answer: "One")).to be_valid
      expect(build(:poll_answer, question: question, answer: "Two")).to be_valid
      expect(build(:poll_answer, question: question, answer: "Three")).to be_valid

      expect(build(:poll_answer, question: question, answer: "Four")).not_to be_valid
    end
  end
end
