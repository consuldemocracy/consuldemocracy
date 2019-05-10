require "rails_helper"

describe Legislation::Question do
  let(:question) { create(:legislation_question) }

  describe "Concerns" do
    it_behaves_like "notifiable"
  end

  it "is valid" do
    expect(question).to be_valid
  end

  context "can be deleted" do
    example "when it has no options or answers" do
      question = create(:legislation_question)

      expect do
        question.destroy
      end.to change { described_class.count }.by(-1)
    end

    example "when it has options but no answers" do
      create(:legislation_question_option, question: question, value: "Yes")
      create(:legislation_question_option, question: question, value: "No")

      expect do
        question.destroy
      end.to change { described_class.count }.by(-1)
    end

    example "when it has options and answers" do
      option_1 = create(:legislation_question_option, question: question, value: "Yes")
      option_2 = create(:legislation_question_option, question: question, value: "No")
      create(:legislation_answer, question: question, question_option: option_1)
      create(:legislation_answer, question: question, question_option: option_2)

      expect do
        question.destroy
      end.to change { described_class.count }.by(-1)
    end
  end

  describe "#next_question_id" do
    let!(:question1) { create(:legislation_question) }
    let!(:question2) { create(:legislation_question, legislation_process_id: question1.legislation_process_id) }

    it "returns the next question" do
      expect(question1.next_question_id).to eq(question2.id)
    end

    it "returns nil" do
      expect(question2.next_question_id).to be_nil
    end
  end

  describe "#first_question_id" do
    let!(:question1) { create(:legislation_question) }
    let!(:question2) { create(:legislation_question, legislation_process_id: question1.legislation_process_id) }

    it "returns the first question" do
      expect(question1.first_question_id).to eq(question1.id)
      expect(question2.first_question_id).to eq(question1.id)
    end
  end

  describe "notifications" do
    it_behaves_like "notifiable"
  end

end
