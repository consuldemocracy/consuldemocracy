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

    it "is not valid without an answer when question is open-ended" do
      answer.question = create(:poll_question_open)
      answer.answer = nil

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

    it "is valid for answers included in the list of titles for the option" do
      question = create(:poll_question)
      option = create(:poll_question_option, title_en: "One", title_es: "Uno", question: question)

      create(:poll_question_option, title: "Two", question: question)
      create(:poll_question_option, title: "Three", question: create(:poll_question, poll: create(:poll)))

      expect(build(:poll_answer, option: option, answer: "One")).to be_valid
      expect(build(:poll_answer, option: option, answer: "Uno")).to be_valid
      expect(build(:poll_answer, option: option, answer: "Two")).not_to be_valid
      expect(build(:poll_answer, option: option, answer: "Three")).not_to be_valid
      expect(build(:poll_answer, option: option, answer: "Any")).not_to be_valid
    end
  end
end
