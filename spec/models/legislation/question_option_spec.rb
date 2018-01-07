require 'rails_helper'

RSpec.describe Legislation::QuestionOption, type: :model do
  let(:legislation_question_option) { build(:legislation_question_option) }

  it "is valid" do
    expect(legislation_question_option).to be_valid
  end

  it "is unique per question" do
    question = create(:legislation_question)
    valid_question_option = create(:legislation_question_option, question: question, value: "uno")

    invalid_question_option = build(:legislation_question_option, question: question, value: "uno")

    expect(invalid_question_option).not_to be_valid
  end
end
