require "rails_helper"

describe Poll::Question::Option do
  it_behaves_like "globalizable", :poll_question_option

  describe "#with_content" do
    it "returns options with a description" do
      option = create(:poll_question_option, description: "I've got a description")

      expect(Poll::Question::Option.with_content).to eq [option]
    end

    it "returns options with images and no description" do
      option = create(:poll_question_option, :with_image, description: "")

      expect(Poll::Question::Option.with_content).to eq [option]
    end

    it "returns options with documents and no description" do
      option = create(:poll_question_option, :with_document, description: "")

      expect(Poll::Question::Option.with_content).to eq [option]
    end

    it "returns options with videos and no description" do
      option = create(:poll_question_option, :with_video, description: "")

      expect(Poll::Question::Option.with_content).to eq [option]
    end

    it "does not return options with no description and no images, documents nor videos" do
      create(:poll_question_option, description: "")

      expect(Poll::Question::Option.with_content).to be_empty
    end
  end

  describe "#with_read_more?" do
    it "returns false when the option does not have description, images, videos nor documents" do
      option = build(:poll_question_option, description: nil)

      expect(option.with_read_more?).to be_falsy
    end

    it "returns true when the option has description, images, videos or documents" do
      option = build(:poll_question_option, description: "Option description")

      expect(option.with_read_more?).to be_truthy

      option = build(:poll_question_option, :with_image)

      expect(option.with_read_more?).to be_truthy

      option = build(:poll_question_option, :with_document)

      expect(option.with_read_more?).to be_truthy

      option = build(:poll_question_option, :with_video)

      expect(option.with_read_more?).to be_truthy
    end
  end
end
