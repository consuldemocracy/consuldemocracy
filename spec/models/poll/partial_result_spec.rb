require "rails_helper"

describe Poll::PartialResult do
  describe "validations" do
    it "validates that the answers are included in the list of titles for the option" do
      question = create(:poll_question)
      option = create(:poll_question_option, title_en: "One", title_es: "Uno", question: question)

      create(:poll_question_option, title: "Two", question: question)
      create(:poll_question_option, title: "Three", question: create(:poll_question, poll: create(:poll)))

      expect(build(:poll_partial_result, option: option, answer: "One")).to be_valid
      expect(build(:poll_partial_result, option: option, answer: "Uno")).to be_valid
      expect(build(:poll_partial_result, option: option, answer: "Two")).not_to be_valid
      expect(build(:poll_partial_result, option: option, answer: "Three")).not_to be_valid
      expect(build(:poll_partial_result, option: option, answer: "Any")).not_to be_valid
    end

    it "dynamically validates the valid origins" do
      stub_const("#{Poll::PartialResult}::VALID_ORIGINS", %w[custom])

      expect(build(:poll_partial_result, origin: "custom")).to be_valid
      expect(build(:poll_partial_result, origin: "web")).not_to be_valid
    end

    describe "option_id uniqueness" do
      let(:booth_assignment) { create(:poll_booth_assignment) }

      it "is not valid when there are two identical partial results" do
        question = create(:poll_question_multiple, :abc)
        option = question.question_options.first

        create(:poll_partial_result,
               question: question,
               booth_assignment: booth_assignment,
               date: Date.current,
               option: option,
               answer: "Answer A")

        partial_result = build(:poll_partial_result,
                               question: question,
                               booth_assignment: booth_assignment,
                               date: Date.current,
                               option: option,
                               answer: "Answer A")

        expect(partial_result).not_to be_valid
        expect { partial_result.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
      end

      it "is not valid when there are two results with the same option and different answer" do
        question = create(:poll_question_multiple, :abc)
        option = question.question_options.first

        create(:poll_partial_result,
               question: question,
               booth_assignment: booth_assignment,
               date: Date.current,
               option: option,
               answer: "Answer A")

        partial_result = build(:poll_partial_result,
                               question: question,
                               booth_assignment: booth_assignment,
                               date: Date.current,
                               option: option,
                               answer: "Answer B")

        expect(partial_result).not_to be_valid
        expect { partial_result.save(validate: false) }.to raise_error ActiveRecord::RecordNotUnique
      end

      it "is valid when there are two identical results and the option is nil" do
        question = create(:poll_question_multiple, :abc)

        create(:poll_partial_result,
               question: question,
               booth_assignment: booth_assignment,
               date: Date.current,
               option: nil,
               answer: "Answer A")

        partial_result = build(:poll_partial_result,
                               question: question,
                               booth_assignment: booth_assignment,
                               date: Date.current,
                               option: nil,
                               answer: "Answer A")

        expect(partial_result).to be_valid
        expect { partial_result.save }.not_to raise_error
      end
    end
  end

  describe "logging changes" do
    it "updates amount_log if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")

      partial_result.amount = 33
      partial_result.save!
      partial_result.amount = 32
      partial_result.save!
      partial_result.amount = 34
      partial_result.save!

      expect(partial_result.amount_log).to eq(":33:32")
    end

    it "updates officer_assignment_id_log if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")
      expect(partial_result.officer_assignment_id_log).to eq("")

      partial_result.amount = 33
      first_assignment = create(:poll_officer_assignment)
      partial_result.officer_assignment = first_assignment
      partial_result.save!

      partial_result.amount = 32
      second_assignment = create(:poll_officer_assignment)
      partial_result.officer_assignment = second_assignment
      partial_result.save!

      partial_result.amount = 34
      partial_result.officer_assignment = create(:poll_officer_assignment)
      partial_result.save!

      expect(partial_result.amount_log).to eq(":33:32")
      expect(partial_result.officer_assignment_id_log).to eq(
        ":#{first_assignment.id}:#{second_assignment.id}"
      )
    end

    it "updates author_id if amount changes" do
      partial_result = create(:poll_partial_result, amount: 33)

      expect(partial_result.amount_log).to eq("")
      expect(partial_result.author_id_log).to eq("")

      author1 = create(:poll_officer).user
      author2 = create(:poll_officer).user
      author3 = create(:poll_officer).user

      partial_result.amount = 33
      partial_result.author_id = author1.id
      partial_result.save!

      partial_result.amount = 32
      partial_result.author_id = author2.id
      partial_result.save!

      partial_result.amount = 34
      partial_result.author_id = author3.id
      partial_result.save!

      expect(partial_result.amount_log).to eq(":33:32")
      expect(partial_result.author_id_log).to eq(":#{author1.id}:#{author2.id}")
    end
  end
end
