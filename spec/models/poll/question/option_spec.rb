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

  describe "#total_votes" do
    let!(:question) { create(:poll_question) }

    context "with translated options" do
      let(:option_yes) { create(:poll_question_option, question: question, title_en: "Yes", title_es: "Sí") }

      it "group votes from different locales for the same option" do
        create(:poll_answer, question: question, option: option_yes, answer: "Sí")
        create(:poll_answer, question: question, option: option_yes, answer: "Yes")

        expect(option_yes.total_votes).to eq 2
      end
    end

    context "with options whose titles collide across locales" do
      let!(:option_a) do
        create(:poll_question_option, question: question, title_en: "Lead", title_es: "Plomo")
      end
      let!(:option_b) do
        create(:poll_question_option, question: question, title_en: "Plomo", title_es: "Lead")
      end

      it "keeps votes isolated to the correct option" do
        create(:poll_answer, question: question, option: option_a, answer: "Plomo")
        create(:poll_answer, question: question, option: option_a, answer: "Lead")

        expect(option_b.total_votes).to eq 0
      end
    end

    context "with partial results" do
      it "sums amounts by option_id" do
        option = create(:poll_question_option, question: question, title_en: "Yes", title_es: "Sí")
        booth_assignment = create(:poll_booth_assignment, poll: question.poll)

        create(:poll_partial_result,
               booth_assignment: booth_assignment,
               question: question,
               option: option,
               answer: "Yes",
               amount: 2)

        create(:poll_partial_result,
               booth_assignment: create(:poll_booth_assignment, poll: question.poll),
               question: question,
               option: option,
               answer: "Sí",
               amount: 3)

        expect(option.total_votes).to eq 5
      end
    end

    context "with both answers and partial results" do
      it "sums poll answers and partial results amounts" do
        option = create(:poll_question_option, question: question, title_en: "Yes", title_es: "Sí")

        create(:poll_answer, question: question, option: option, answer: "Yes")
        create(:poll_answer, question: question, option: option, answer: "Sí")

        create(:poll_partial_result,
               booth_assignment: create(:poll_booth_assignment, poll: question.poll),
               question: question,
               option: option,
               answer: "Yes",
               amount: 2)

        create(:poll_partial_result,
               booth_assignment: create(:poll_booth_assignment, poll: question.poll),
               question: question,
               option: option,
               answer: "Sí",
               amount: 3)

        expect(option.total_votes).to eq 7
      end
    end
  end
end
