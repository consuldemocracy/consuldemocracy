require "rails_helper"

describe Polls::Results::QuestionComponent do
  let(:poll) { create(:poll) }
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
