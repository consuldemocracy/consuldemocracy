require "rails_helper"

describe Legislation::QuestionOption do
  let(:legislation_question_option) { build(:legislation_question_option) }

  it_behaves_like "acts as paranoid", :legislation_question_option
  it_behaves_like "globalizable", :legislation_question_option

  it "is valid" do
    expect(legislation_question_option).to be_valid
  end
end
