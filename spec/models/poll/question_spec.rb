require "rails_helper"

RSpec.describe Poll::Question do
  let(:poll_question) { build(:poll_question) }

  describe "Concerns" do
    it_behaves_like "acts as paranoid", :poll_question
    it_behaves_like "globalizable", :poll_question
  end

  describe "#poll_question_id" do
    it "is invalid if a poll is not selected" do
      poll_question.poll_id = nil
      expect(poll_question).not_to be_valid
    end

    it "is valid if a poll is selected" do
      poll_question.poll_id = 1
      expect(poll_question).to be_valid
    end
  end

  describe "#copy_attributes_from_proposal" do
    before { create_list(:geozone, 3) }
    let(:proposal) { create(:proposal) }

    it "copies the attributes from the proposal" do
      poll_question.copy_attributes_from_proposal(proposal)
      expect(poll_question.author).to eq(proposal.author)
      expect(poll_question.author_visible_name).to eq(proposal.author.name)
      expect(poll_question.proposal_id).to eq(proposal.id)
      expect(poll_question.title).to eq(proposal.title)
    end

    context "locale with non-underscored name" do
      it "correctly creates a translation" do
        I18n.with_locale(:"pt-BR") do
          poll_question.copy_attributes_from_proposal(proposal)
        end

        translation = poll_question.translations.first

        expect(poll_question.title).to eq(proposal.title)
        expect(translation.title).to eq(proposal.title)
        expect(translation.locale).to eq(:"pt-BR")
      end
    end
  end

  describe "#find_or_initialize_user_answer" do
    let(:user) { create(:user) }

    context "non essay question" do
      let(:question) { create(:poll_question_multiple, :abc) }
      let(:answer_a) { question.question_options.find_by(title: "Answer A") }
      let(:answer_b) { question.question_options.find_by(title: "Answer B") }

      it "sets option and answer (title) and clears text_answer" do
        answer = question.find_or_initialize_user_answer(user, answer_a.id, nil)

        expect(answer.option).to eq(answer_a)
        expect(answer.answer).to eq(answer_a.title)
        expect(answer.text_answer).to be nil
      end

      it "sets option and answer to nil when option_id is invalid or nil" do
        invalid = question.find_or_initialize_user_answer(user, 999999, nil)
        expect(invalid.option).to be nil
        expect(invalid.answer).to be nil
        expect(invalid.text_answer).to be nil

        blank = question.find_or_initialize_user_answer(user, nil, "ignored")
        expect(blank.option).to be nil
        expect(blank.answer).to be nil
        expect(blank.text_answer).to be nil
      end
    end

    context "essay question" do
      let(:question) { create(:poll_question_essay) }

      it "ignores option_id and assigns only text_answer, with option and answer set to nil" do
        answer = question.find_or_initialize_user_answer(user, 123, "Hi")
        expect(answer.option).to be nil
        expect(answer.answer).to be nil
        expect(answer.text_answer).to eq("Hi")
      end

      it "reuses the existing answer for the user and updates text_answer" do
        existing = create(:poll_answer, question: question, author: user, text_answer: "Before")

        result = question.find_or_initialize_user_answer(user, nil, "After")
        expect(result).to eq(existing)
        expect(result.text_answer).to eq("After")
      end
    end
  end
end
