require "rails_helper"

describe Polls::ResultsComponent do
  let(:poll) { create(:poll) }

  let(:question_1) { create(:poll_question, poll: poll, title: "Do you like Consul Democracy?") }
  let(:option_yes) { create(:poll_question_option, question: question_1, title: "Yes") }
  let(:option_no) { create(:poll_question_option, question: question_1, title: "No") }

  let(:question_2) { create(:poll_question, poll: poll, title: "What's your favorite color?") }
  let(:option_blue) { create(:poll_question_option, question: question_2, title: "Blue") }
  let(:option_green) { create(:poll_question_option, question: question_2, title: "Green") }
  let(:option_yellow) { create(:poll_question_option, question: question_2, title: "Yellow") }

  it "renders results content" do
    create_list(:poll_answer, 2, question: question_1, option: option_yes)
    create(:poll_answer, question: question_1, option: option_no)

    create(:poll_answer, question: question_2, option: option_blue)
    create(:poll_answer, question: question_2, option: option_green)
    create(:poll_answer, question: question_2, option: option_yellow)

    render_inline Polls::ResultsComponent.new(poll)

    expect(page).to have_content "Do you like Consul Democracy?"

    page.find("#question_#{question_1.id}_results_table") do |table|
      expect(table).to have_css "#option_#{option_yes.id}_result", text: "2 (66.67%)", normalize_ws: true
      expect(table).to have_css "#option_#{option_no.id}_result", text: "1 (33.33%)", normalize_ws: true
    end

    expect(page).to have_content "What's your favorite color?"

    page.find("#question_#{question_2.id}_results_table") do |table|
      expect(table).to have_css "#option_#{option_blue.id}_result", text: "1 (33.33%)", normalize_ws: true
      expect(table).to have_css "#option_#{option_green.id}_result", text: "1 (33.33%)", normalize_ws: true
      expect(table).to have_css "#option_#{option_yellow.id}_result", text: "1 (33.33%)", normalize_ws: true
    end
  end

  it "renders results for polls with questions but without answers" do
    poll = create(:poll, :expired, results_enabled: true)
    question = create(:poll_question, poll: poll)

    render_inline Polls::ResultsComponent.new(poll)

    expect(page).to have_content question.title
  end
end
