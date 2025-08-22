require "rails_helper"

describe Polls::ResultsComponent do
  let(:poll) { create(:poll) }

  let(:question_1) { create(:poll_question, :yes_no, poll: poll, title: "Do you like Consul Democracy?") }
  let(:option_yes) { question_1.question_options.find_by(title: "Yes") }
  let(:option_no) { question_1.question_options.find_by(title: "No") }

  let(:question_2) { create(:poll_question, :abc, poll: poll, title: "Which option do you prefer?") }
  let(:option_a) { question_2.question_options.find_by(title: "Answer A") }
  let(:option_b) { question_2.question_options.find_by(title: "Answer B") }
  let(:option_c) { question_2.question_options.find_by(title: "Answer C") }

  it "renders results content" do
    create_list(:poll_answer, 2, question: question_1, option: option_yes)
    create(:poll_answer, question: question_1, option: option_no)

    create(:poll_answer, question: question_2, option: option_a)
    create(:poll_answer, question: question_2, option: option_b)
    create(:poll_answer, question: question_2, option: option_c)

    render_inline Polls::ResultsComponent.new(poll)

    expect(page).to have_content "Do you like Consul Democracy?"
    expect(page).to have_table "question_#{question_1.id}_results_table",
                               with_rows: [{ "Most voted answer: Yes" => "2 (66.67%)",
                                             "No" => "1 (33.33%)" }]

    expect(page).to have_content "Which option do you prefer?"
    expect(page).to have_table "question_#{question_2.id}_results_table",
                               with_rows: [{ "Most voted answer: Answer A" => "1 (33.33%)",
                                             "Answer B" => "1 (33.33%)",
                                             "Answer C" => "1 (33.33%)" }]
  end
end
