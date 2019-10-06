require "rails_helper"

describe Poll::PairAnswer do

  describe "validations" do

    let(:pair_answer) { build(:poll_pair_answer) }

    it "is valid" do
      expect(pair_answer).to be_valid
    end

    it "is not valid wihout a question" do
      pair_answer.question = nil

      expect(pair_answer).not_to be_valid
    end

    it "is not valid without an author" do
      pair_answer.author = nil

      expect(pair_answer).not_to be_valid
    end

    it "is valid if answer_left is included in the Poll::Question's question_answers list" do
      question = create(:poll_question)
      answer1 = create(:poll_question_answer, title: "One", question: question)
      answer2 = create(:poll_question_answer, title: "Two", question: question)
      answer3 = create(:poll_question_answer, title: "Three")

      expect(build(:poll_pair_answer, question: question, answer_left: answer1)).to be_valid
      expect(build(:poll_pair_answer, question: question, answer_left: answer2)).to be_valid
      expect(build(:poll_pair_answer, question: question, answer_left: answer3)).not_to be_valid
    end

    it "is valid if answer_right is included in the Poll::Question's question_answers list" do
      question = create(:poll_question)
      answer1 = create(:poll_question_answer, title: "One", question: question)
      answer2 = create(:poll_question_answer, title: "Two", question: question)
      answer3 = create(:poll_question_answer, title: "Three")

      expect(build(:poll_pair_answer, question: question, answer_right: answer1)).to be_valid
      expect(build(:poll_pair_answer, question: question, answer_right: answer2)).to be_valid
      expect(build(:poll_pair_answer, question: question, answer_right: answer3)).not_to be_valid
    end
  end

  context "scopes" do
    let(:pair_answer_1) { create(:poll_pair_answer) }
    let(:pair_answer_2) { create(:poll_pair_answer) }

    describe "#by_author" do

      it "returns pair_answers associated to an user" do
        author = pair_answer_1.author

        expect(Poll::PairAnswer.by_author(author)).to eq [pair_answer_1]
      end

    end

    describe "#by_question" do

      it "returns pair_answers associated to a question" do
        question = pair_answer_1.question

        expect(Poll::PairAnswer.by_question(question)).to eq [pair_answer_1]
      end
    end

  end

  describe "#generate_pair" do
    let(:user) { create(:user) }
    let(:question) { create(:poll_question) }

    context "without question_answers" do

      it "assigns nil value to pair_answers" do
        pair_answer = Poll::PairAnswer.generate_pair(question, user)

        expect(pair_answer).to be_a Poll::PairAnswer
        expect(pair_answer.question).to eq(question)
        expect(pair_answer.author).to eq(user)
        expect(pair_answer.answer_left).to be_nil
        expect(pair_answer.answer_right).to be_nil
      end
    end

    context "With question answers" do
      let!(:answer1) { create(:poll_question_answer, question: question) }

      it "assigns only right question if only has one question_answer" do
        pair_answer = Poll::PairAnswer.generate_pair(question, user)

        expect(pair_answer).to be_a Poll::PairAnswer
        expect(pair_answer.question).to eq(question)
        expect(pair_answer.author).to eq(user)
        expect(pair_answer.answer_left).to eq(answer1)
        expect(pair_answer.answer_right).to be_nil
      end

      it "assigns random values if question has some question_answer" do
        create(:poll_question_answer, question: question)

        pair_answer = Poll::PairAnswer.generate_pair(question, user)

        expect(pair_answer).to be_a Poll::PairAnswer
        expect(pair_answer.question).to eq(question)
        expect(pair_answer.author).to eq(user)
        expect(pair_answer.answer_left).to be_a Poll::Question::Answer
        expect(pair_answer.answer_right).to be_a Poll::Question::Answer
        expect(pair_answer.answer_left).not_to eq(pair_answer.answer_right)
      end
    end
  end

  describe "#answers" do
    let(:pair_answer) { create(:poll_pair_answer) }

    it "returns an array of answers" do
      expect(pair_answer.answers).to eq [pair_answer.answer_left, pair_answer.answer_right]
    end
  end

end
