require "rails_helper"

describe Poll::Question::Answer do
  it_behaves_like "globalizable", :poll_question_answer

  describe "#with_content" do
    it "returns answers with a description" do
      answer = create(:poll_question_answer, description: "I've got a description")

      expect(Poll::Question::Answer.with_content).to eq [answer]
    end

    it "returns answers with images and no description" do
      answer = create(:poll_question_answer, :with_image, description: "")

      expect(Poll::Question::Answer.with_content).to eq [answer]
    end

    it "returns answers with documents and no description" do
      question = create(:poll_question_answer, :with_document, description: "")

      expect(Poll::Question::Answer.with_content).to eq [question]
    end

    it "returns answers with videos and no description" do
      question = create(:poll_question_answer, :with_video, description: "")

      expect(Poll::Question::Answer.with_content).to eq [question]
    end

    it "does not return answers with no description and no images, documents nor videos" do
      create(:poll_question_answer, description: "")

      expect(Poll::Question::Answer.with_content).to be_empty
    end
  end

  describe "#with_read_more?" do
    it "returns false when the answer does not have description, images, videos nor documents" do
      poll_question_answer = build(:poll_question_answer, description: nil)

      expect(poll_question_answer.with_read_more?).to be_falsy
    end

    it "returns true when the answer has description, images, videos or documents" do
      poll_question_answer = build(:poll_question_answer, description: "Answer description")

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_image)

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_document)

      expect(poll_question_answer.with_read_more?).to be_truthy

      poll_question_answer = build(:poll_question_answer, :with_video)

      expect(poll_question_answer.with_read_more?).to be_truthy
    end
  end
end
