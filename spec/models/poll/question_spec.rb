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

  describe "scopes" do
    describe ".for_physical_votes" do
      it "returns unique and multiple, but not open_ended" do
        question_unique = create(:poll_question_unique)
        question_multiple = create(:poll_question_multiple)
        question_open_ended = create(:poll_question_open)

        result = Poll::Question.for_physical_votes

        expect(result).to match_array [question_unique, question_multiple]
        expect(result).not_to include question_open_ended
      end
    end
  end

  context "open-ended results" do
    let(:poll) { create(:poll) }
    let!(:question_open) { create(:poll_question_open, poll: poll) }

    it "includes voters who didn't answer any questions in blank answers count" do
      create(:poll_voter, poll: poll)

      expect(question_open.open_ended_blank_answers_count).to eq 1
      expect(question_open.open_ended_valid_answers_count).to eq 0
    end

    describe "#open_ended_valid_answers_count" do
      it "returns 0 when there are no answers" do
        expect(question_open.open_ended_valid_answers_count).to eq 0
      end

      it "counts answers" do
        create(:poll_answer, question: question_open, answer: "Hello")
        create(:poll_answer, question: question_open, answer: "Bye")

        expect(question_open.open_ended_valid_answers_count).to eq 2
      end
    end

    describe "#open_ended_blank_answers_count" do
      let(:another_question) { create(:poll_question, :yes_no, poll: poll) }
      let(:option_yes) { another_question.question_options.find_by(title: "Yes") }
      let(:option_no) { another_question.question_options.find_by(title: "No") }

      it "counts valid participants of the poll who did not answer the open-ended question" do
        voters = create_list(:poll_voter, 3, poll: poll)
        voters.each do |voter|
          create(:poll_answer, question: another_question, author: voter.user, option: option_yes)
        end
        create(:poll_answer, question: question_open, author: voters.sample.user, answer: "Free text")

        expect(question_open.open_ended_valid_answers_count).to eq 1
        expect(question_open.open_ended_blank_answers_count).to eq 2
      end

      it "returns 0 when there are no valid participants in the poll" do
        expect(question_open.open_ended_blank_answers_count).to eq 0
      end

      it "counts every user one time even if they answered many questions" do
        multiple_question = create(:poll_question_multiple, :abc, poll: poll)
        option_a = multiple_question.question_options.find_by(title: "Answer A")
        option_b = multiple_question.question_options.find_by(title: "Answer B")
        another_question_open = create(:poll_question_open, poll: poll)

        voter = create(:poll_voter, poll: poll)

        create(:poll_answer, question: multiple_question, author: voter.user, option: option_a)
        create(:poll_answer, question: multiple_question, author: voter.user, option: option_b)
        create(:poll_answer, question: another_question, author: voter.user, option: option_yes)
        create(:poll_answer, question: another_question_open, author: voter.user, answer: "Free text")

        expect(question_open.open_ended_blank_answers_count).to eq 1
      end
    end

    describe "percentages" do
      it "returns 0.0 when there aren't any answers" do
        expect(question_open.open_ended_valid_percentage).to eq 0.0
        expect(question_open.open_ended_blank_percentage).to eq 0.0
      end

      it "calculates valid and blank percentages based on counts" do
        another_question = create(:poll_question, :yes_no, poll: poll)
        option_yes = another_question.question_options.find_by(title: "Yes")

        voters = create_list(:poll_voter, 4, poll: poll)
        voters.each do |voter|
          create(:poll_answer, question: another_question, author: voter.user, option: option_yes)
        end
        create(:poll_answer, question: question_open, author: voters.sample.user, answer: "A")

        expect(question_open.open_ended_valid_percentage).to eq 25.0
        expect(question_open.open_ended_blank_percentage).to eq 75.0
      end
    end
  end
end
