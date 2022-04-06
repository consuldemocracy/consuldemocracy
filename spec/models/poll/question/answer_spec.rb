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
end
