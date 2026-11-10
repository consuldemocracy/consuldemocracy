require "rails_helper"

describe Poll::Question::Option do
  it_behaves_like "globalizable", :poll_question_option

  describe "validations" do
    it "is valid" do
      expect(build(:poll_question_option)).to be_valid
    end

    it "is not valid with an alphanumerical given_order" do
      expect(build(:poll_question_option, given_order: "3fb0")).not_to be_valid
    end

    it "is not valid with a decimal given_order" do
      expect(build(:poll_question_option, given_order: 3.5)).not_to be_valid
    end
  end

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

      it "counts legacy answers with text and new answers without text" do
        create(:poll_answer, question: question, option: option_yes, answer: "Yes")
        create(:poll_answer, question: question, option: option_yes, answer: nil)

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

  describe "#allow_custom_text" do
    it "defaults to false" do
      option = Poll::Question::Option.new

      expect(option.allow_custom_text).to be false
    end

    it "can be enabled" do
      option = create(:poll_question_option, allow_custom_text: true)

      expect(option.allow_custom_text).to be true
    end
  end

  describe "#given_order_or_last" do
    it "defaults to 1 with no question when there are no other options" do
      option = Poll::Question::Option.new

      expect(option.given_order_or_last).to eq 1
    end

    it "defaults to 1 with no question when there are options without a question" do
      create(:poll_question_option, given_order: 1, question: nil)
      option = Poll::Question::Option.new

      expect(option.given_order_or_last).to eq 1
    end

    it "defaults to 1 with a new question when there are options without a question" do
      create(:poll_question_option, given_order: 1, question: nil)
      option = Poll::Question::Option.new(question: build(:poll_question))

      expect(option.given_order_or_last).to eq 1
    end

    it "defaults to 1 when there are no other options for the question" do
      option = Poll::Question::Option.new(question: create(:poll_question))

      expect(option.given_order_or_last).to eq 1
    end

    it "defaults to the last position when there are other options" do
      existing = create(:poll_question_option, given_order: 1)
      option = Poll::Question::Option.new(question: existing.question)

      expect(option.given_order_or_last).to eq 2
    end

    it "returns the assigned given order when present" do
      existing = create(:poll_question_option, given_order: 4)
      option = Poll::Question::Option.new(question: existing.question, given_order: 2)

      expect(option.given_order_or_last).to eq 2
    end

    it "is automatically assigned to new records on validation" do
      option = build(:poll_question_option, given_order: nil)

      option.valid?

      expect(option.given_order).to eq 1
    end

    it "is not automatically assigned to persisted records on validation" do
      option = create(:poll_question_option)
      option.given_order = nil

      option.valid?

      expect(option.given_order).to be nil
    end
  end

  describe "#reorder_options" do
    it "reorders existing options when there's a conflicting given order" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")
      create(:poll_question_option, question: question, given_order: 2, title: "Was second")
      create(:poll_question_option, question: question, given_order: 3, title: "Last")

      Poll::Question::Option.create!(question: question, given_order: 2, title: "New second")

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "First" => 1, "New second" => 2, "Was second" => 3, "Last" => 4
      })
    end

    it "inserts in the last position when `given_order` exceeds the amount of options" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")

      Poll::Question::Option.create!(question: question, given_order: 5, title: "Last")

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "First" => 1, "Last" => 2
      })
    end

    it "reorders existing options when an option is moved to an earlier position" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "Was first")
      was_second = create(:poll_question_option, question: question, given_order: 2, title: "Was second")
      create(:poll_question_option, question: question, given_order: 3, title: "Last")

      was_second.update!(given_order: 1)

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "Was second" => 1, "Was first" => 2, "Last" => 3
      })
    end

    it "reorders existing options when an option is moved to a later position" do
      question = create(:poll_question)
      was_first = create(:poll_question_option, question: question, given_order: 1, title: "Was first")
      create(:poll_question_option, question: question, given_order: 2, title: "Was second")
      create(:poll_question_option, question: question, given_order: 3, title: "Was last")

      was_first.update!(given_order: 3)

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "Was second" => 1, "Was last" => 2, "Was first" => 3
      })
    end

    it "reorders existing options after destroy one" do
      question = create(:poll_question)
      was_first = create(:poll_question_option, question: question, given_order: 1, title: "Was first")
      create(:poll_question_option, question: question, given_order: 2, title: "Was second")
      create(:poll_question_option, question: question, given_order: 3, title: "Was last")

      was_first.destroy!

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "Was second" => 1, "Was last" => 2
      })
    end

    it "does not reorder existing options when the option is the last one" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")
      create(:poll_question_option, question: question, given_order: 2, title: "Second")
      create(:poll_question_option, question: question, given_order: 3, title: "Was last")

      Poll::Question::Option.create!(question: question, given_order: 4, title: "New last")

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "First" => 1, "Second" => 2, "Was last" => 3, "New last" => 4
      })
    end

    it "does not reorder existing options when the options fills a gap" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")
      create(:poll_question_option, question: question, given_order: 2, title: "Second")
      create(:poll_question_option, question: question, given_order: 4, title: "Last")

      Poll::Question::Option.create!(question: question, given_order: 3, title: "Third")

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "First" => 1, "Second" => 2, "Third" => 3, "Last" => 4
      })
    end

    it "does not reorder when the option isn't valid" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")

      Poll::Question::Option.create(question: question, given_order: 1)

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({ "First" => 1 })
    end

    it "does not reorder when given_order didn't change" do
      question = create(:poll_question)
      create(:poll_question_option, question: question, given_order: 1, title: "First")
      option = create(:poll_question_option, question: question, title: "Second")
      option.update_column(:given_order, 1)

      option.update!(title: "Also first")

      expect(Poll::Question::Option.pluck(:title, :given_order).to_h).to eq({
        "First" => 1, "Also first" => 1
      })
    end

    it "does not crash when the question doesn't have an option" do
      expect { create(:poll_question_option, question: nil) }.not_to raise_exception
    end
  end
end
