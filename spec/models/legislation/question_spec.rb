require 'rails_helper'

RSpec.describe Legislation::Question, type: :model do
  let(:legislation_question) { build(:legislation_question) }

  it "should be valid" do
    expect(legislation_question).to be_valid
  end

  context "can be deleted" do
    example "when it has no options or answers" do
      question = create(:legislation_question)

      expect do
        question.destroy
      end.to change { Legislation::Question.count }.by(-1)
    end

    example "when it has options but no answers" do
      question = create(:legislation_question)
      create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_question_option, question: question, value: "No")

      expect do
        question.destroy
      end.to change { Legislation::Question.count }.by(-1)
    end

    example "when it has options and answers" do
      question = create(:legislation_question)
      option_1 = create(:legislation_question_option, question: question, value: "Yes")
      option_2 = create(:legislation_question_option, question: question, value: "No")
      create(:legislation_answer, question: question, question_option: option_1)
      create(:legislation_answer, question: question, question_option: option_2)

      expect do
        question.destroy
      end.to change { Legislation::Question.count }.by(-1)
    end
  end
end
