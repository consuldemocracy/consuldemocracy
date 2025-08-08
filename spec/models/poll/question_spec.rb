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

  describe "#options_total_votes" do
    let!(:question) { create(:poll_question) }
    let!(:option_yes) { create(:poll_question_option, question: question, title_en: "Yes", title_es: "Sí") }
    let!(:option_no) { create(:poll_question_option, question: question, title_en: "No", title_es: "No") }

    before do
      create(:poll_answer, question: question, option: option_yes, answer: "Sí")
      create(:poll_answer, question: question, option: option_yes, answer: "Yes")
      create(:poll_answer, question: question, option: option_no, answer: "No")
    end

    it "includes answers in every language" do
      expect(question.options_total_votes).to eq 3
    end

    it "includes partial results counted by option_id" do
      booth_assignment = create(:poll_booth_assignment, poll: question.poll)
      create(:poll_partial_result,
             booth_assignment: booth_assignment,
             question: question,
             option: option_yes,
             amount: 4)

      expect(question.options_total_votes).to eq 7
    end

    it "does not include votes from other questions even with same answer text" do
      other_question = create(:poll_question, poll: question.poll)
      other_option_yes = create(:poll_question_option,
                                question: other_question,
                                title_en: "Yes",
                                title_es: "Sí")

      create(:poll_partial_result, question: other_question, option: other_option_yes, amount: 4)
      create(:poll_answer, question: other_question, option: other_option_yes, answer: "Yes")

      expect(question.options_total_votes).to eq 3
    end
  end

  describe "#find_or_initialize_user_answer" do
    let(:user) { create(:user) }
    let(:other_user) { create(:user) }

    context "unique question" do
      let(:question) { create(:poll_question_unique, :abc) }
      let(:answer_a) { question.question_options.find_by(title: "Answer A") }
      let(:answer_b) { question.question_options.find_by(title: "Answer B") }

      it "finds the existing answer for the same user" do
        existing_answer = create(:poll_answer, question: question, author: user, option: answer_a)
        create(:poll_answer, question: question, author: other_user, option: answer_b)

        answer = question.find_or_initialize_user_answer(user, option_id: answer_b.id)

        expect(answer).to eq existing_answer
        expect(answer.author).to eq user
        expect(answer.option).to eq answer_b
        expect(answer.answer).to eq "Answer B"
      end

      it "initializes a new answer when only another user has answered" do
        create(:poll_answer, question: question, author: other_user, option: answer_a)

        answer = question.find_or_initialize_user_answer(user, option_id: answer_a.id)

        expect(answer).to be_new_record
        expect(answer.author).to eq user
        expect(answer.option).to eq answer_a
        expect(answer.answer).to eq "Answer A"
      end

      it "raises when option_id is invalid" do
        expect do
          question.find_or_initialize_user_answer(user, option_id: 999999)
        end.to raise_error(ActiveRecord::RecordNotFound)
      end

      it "raises when option_id is nil" do
        expect do
          question.find_or_initialize_user_answer(user, answer_text: "ignored")
        end.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context "multiple question" do
      let(:question) { create(:poll_question_multiple, :abc, max_votes: 3) }
      let(:answer_a) { question.question_options.find_by(title: "Answer A") }
      let(:answer_b) { question.question_options.find_by(title: "Answer B") }

      it "finds the existing answer for the same user and option" do
        existing_answer = create(:poll_answer, question: question, author: user, option: answer_a)
        create(:poll_answer, question: question, author: other_user, option: answer_a)

        answer = question.find_or_initialize_user_answer(user, option_id: answer_a.id)

        expect(answer).to eq existing_answer
        expect(answer.author).to eq user
        expect(answer.option).to eq answer_a
        expect(answer.answer).to eq "Answer A"
      end

      it "initializes a new answer when selecting a different option" do
        create(:poll_answer, question: question, author: user, option: answer_a)
        create(:poll_answer, question: question, author: other_user, option: answer_b)

        answer = question.find_or_initialize_user_answer(user, option_id: answer_b.id)

        expect(answer).to be_new_record
        expect(answer.author).to eq user
        expect(answer.option).to eq answer_b
        expect(answer.answer).to eq "Answer B"
      end
    end

    context "Open-ended question" do
      let(:question) { create(:poll_question_open) }

      it "ignores invalid option_id and uses answer_text" do
        answer = question.find_or_initialize_user_answer(user, option_id: 999999, answer_text: "Hi")
        expect(answer.option).to be nil
        expect(answer.answer).to eq "Hi"
      end

      it "ignores option_id when nil and assigns answer with option set to nil" do
        answer = question.find_or_initialize_user_answer(user, answer_text: "Hi")

        expect(answer.option).to be nil
        expect(answer.answer).to eq "Hi"
      end

      it "reuses the existing poll answer for the user and updates answer" do
        existing = create(:poll_answer, question: question, author: user, answer: "Before")

        answer = question.find_or_initialize_user_answer(user, answer_text: "After")
        expect(answer).to eq existing
        expect(answer.author).to eq user
        expect(answer.answer).to eq "After"
      end
    end
  end
end
