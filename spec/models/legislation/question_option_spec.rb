require "rails_helper"

RSpec.describe Legislation::QuestionOption, type: :model do
  let(:legislation_question_option) { build(:legislation_question_option) }

  it "is valid" do
    expect(legislation_question_option).to be_valid
  end
end
