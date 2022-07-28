require "rails_helper"

describe Poll::PartialResult do
  describe "validations" do
    it "validates that the answers are included in the Poll::Question's list" do
      question = create(:poll_question)
      create(:poll_question_answer, title: "One", question: question)
      create(:poll_question_answer, title: "Two", question: question)
      create(:poll_question_answer, title: "Three", question: question)

      expect(build(:poll_partial_result, question: question, answer: "One")).to be_valid
      expect(build(:poll_partial_result, question: question, answer: "Two")).to be_valid
      expect(build(:poll_partial_result, question: question, answer: "Three")).to be_valid

      expect(build(:poll_partial_result, question: question, answer: "Four")).not_to be_valid
    end

    it "dynamically validates the valid origins" do
      stub_const("#{Poll::PartialResult}::VALID_ORIGINS", %w[custom])

      expect(build(:poll_partial_result, origin: "custom")).to be_valid
      expect(build(:poll_partial_result, origin: "web")).not_to be_valid
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
