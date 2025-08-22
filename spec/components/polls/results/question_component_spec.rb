require "rails_helper"

describe Polls::Results::QuestionComponent do
  let(:poll) { create(:poll) }

  context "question is not essay" do
    let(:question) { create(:poll_question, poll: poll) }
    let(:option_yes) { create(:poll_question_option, question: question, title: "Yes") }
    let(:option_no) { create(:poll_question_option, question: question, title: "No") }

    it "renders results table content" do
      create(:poll_answer, question: question, option: option_yes)
      create(:poll_answer, question: question, option: option_no)

      render_inline Polls::Results::QuestionComponent.new(question)

      page.find("#question_#{question.id}_results_table") do |table|
        expect(table).to have_css "#option_#{option_yes.id}_result", text: "1 (50.0%)", normalize_ws: true
        expect(table).to have_css "#option_#{option_no.id}_result", text: "1 (50.0%)", normalize_ws: true
        expect(table).to have_css "th.win", count: 2
        expect(table).to have_css "td.win", count: 2
      end
    end
  end

  context "question is essay" do
    let(:essay_question) { create(:poll_question_essay, poll: poll) }

    it "renders essay headers and empty counts when there are no participants" do
      render_inline Polls::Results::QuestionComponent.new(essay_question)

      page.find("#question_#{essay_question.id}_results_table") do |table|
        expect(table).to have_css "th", text: "With answer"
        expect(table).to have_css "th", text: "Without answer"
        with_answer    = "#question_#{essay_question.id}_with_answer_result"
        without_answer = "#question_#{essay_question.id}_without_answer_result"
        expect(table).to have_css with_answer, text: "0 (0.0%)", normalize_ws: true
        expect(table).to have_css without_answer, text: "0 (0.0%)", normalize_ws: true
      end
    end

    it "render counts for answered/unanswered among valid poll participants" do
      other_question = create(:poll_question, :yes_no, poll: poll)
      option_yes = other_question.question_options.find_by(title: "Yes")

      user_1 = create(:user)
      user_2 = create(:user)
      user_3 = create(:user)
      user_4 = create(:user)

      create(:poll_answer, question: other_question, author: user_1, option: option_yes)
      create(:poll_answer, question: other_question, author: user_2, option: option_yes)
      create(:poll_answer, question: other_question, author: user_3, option: option_yes)
      create(:poll_answer, question: other_question, author: user_4, option: option_yes)

      create(:poll_answer, question: essay_question, author: user_1, text_answer: "Open text A")
      create(:poll_answer, question: essay_question, author: user_2, text_answer: "Open text B")
      create(:poll_answer, question: essay_question, author: user_3, text_answer: "Open text C")

      render_inline Polls::Results::QuestionComponent.new(essay_question)

      page.find("#question_#{essay_question.id}_results_table") do |table|
        with_answer    = "#question_#{essay_question.id}_with_answer_result"
        without_answer = "#question_#{essay_question.id}_without_answer_result"
        expect(table).to have_css with_answer, text: "3 (75.0%)", normalize_ws: true
        expect(table).to have_css without_answer, text: "1 (25.0%)", normalize_ws: true
      end
    end
  end
end
