require "rails_helper"

describe Polls::Results::QuestionComponent do
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll) }
  let(:option_yes) { create(:poll_question_option, question: question, title: "Yes") }
  let(:option_no) { create(:poll_question_option, question: question, title: "No") }

  it "renders results table content" do
    create_list(:poll_answer, 2, question: question, option: option_yes)
    create(:poll_answer, question: question, option: option_no)

    render_inline Polls::Results::QuestionComponent.new(question)

    page.find("#question_#{question.id}_results_table") do |table|
      expect(table).to have_css "#option_#{option_yes.id}_result", text: "2 (66.67%)", normalize_ws: true
      expect(table).to have_css "#option_#{option_no.id}_result", text: "1 (33.33%)", normalize_ws: true
    end
  end

  it "renders results for polls with questions but without answers" do
    render_inline Polls::Results::QuestionComponent.new(question)

    expect(page).to have_content question.title
  end
end
