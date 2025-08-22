require "rails_helper"

describe Polls::Results::QuestionComponent do
  context "question that accepts options" do
    let(:question) { create(:poll_question, :yes_no) }
    let(:option_yes) { question.question_options.find_by(title: "Yes") }
    let(:option_no) { question.question_options.find_by(title: "No") }

    it "renders results table content" do
      create(:poll_answer, question: question, option: option_yes)
      create(:poll_answer, question: question, option: option_no)

      render_inline Polls::Results::QuestionComponent.new(question)

      expect(page).to have_table with_rows: [{ "Most voted answer: Yes" => "1 (50.0%)",
                                               "No" => "1 (50.0%)" }]

      page.find("table") do |table|
        expect(table).to have_css "th.win", count: 1
        expect(table).to have_css "td.win", count: 1
      end
    end
  end

  context "question that does not accept options" do
    let(:open_ended_question) { create(:poll_question_open) }

    it "renders open_ended headers and empty counts when there are no participants" do
      render_inline Polls::Results::QuestionComponent.new(open_ended_question)

      expect(page).to have_table with_rows: [{ "Valid" => "0 (0.0%)",
                                               "Blank" => "0 (0.0%)" }]
    end

    it "renders counts and percentages provided by the model metrics" do
      allow(open_ended_question).to receive_messages(
        open_ended_valid_answers_count: 3,
        open_ended_blank_answers_count: 1
      )

      render_inline Polls::Results::QuestionComponent.new(open_ended_question)

      expect(page).to have_table with_rows: [{ "Valid" => "3 (75.0%)",
                                               "Blank" => "1 (25.0%)" }]
    end
  end
end
