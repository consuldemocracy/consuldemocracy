require "rails_helper"

describe Admin::Poll::Results::QuestionComponent do
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll, title: "What do you want?") }

  before do
    create(:poll_question_option, question: question, title: "Yes")
    create(:poll_question_option, question: question, title: "No")
  end

  it "renders question title and headers" do
    render_inline Admin::Poll::Results::QuestionComponent.new(question, poll.partial_results)

    expect(page).to have_css "h3", text: "What do you want?"
    expect(page).to have_css "th", text: "Answer"
    expect(page).to have_css "th", text: "Votes"
  end

  it "renders one row per option" do
    render_inline Admin::Poll::Results::QuestionComponent.new(question, poll.partial_results)

    expect(page).to have_css "tbody tr", count: 2
    expect(page).to have_css "td", text: "Yes"
    expect(page).to have_css "td", text: "No"
  end

  it "sums votes by answer title" do
    create(:poll_partial_result, question: question, answer: "Yes", amount: 2)
    create(:poll_partial_result, question: question, answer: "Yes", amount: 1)
    create(:poll_partial_result, question: question, answer: "No", amount: 5)

    render_inline Admin::Poll::Results::QuestionComponent.new(question, question.partial_results)

    page.find("tr#question_#{question.id}_0_result") do |yes_result|
      expect(yes_result).to have_css "td", text: "Yes"
      expect(yes_result).to have_css "td", text: "3"
    end

    page.find("tr#question_#{question.id}_1_result") do |no_result|
      expect(no_result).to have_css "td", text: "No"
      expect(no_result).to have_css "td", text: "5"
    end
  end

  it "shows 0 when an option has no partial results" do
    render_inline Admin::Poll::Results::QuestionComponent.new(question, poll.partial_results)

    page.find("tr#question_#{question.id}_0_result") do |yes_result|
      expect(yes_result).to have_css "td", text: "Yes"
      expect(yes_result).to have_css "td", text: "0"
    end

    page.find("tr#question_#{question.id}_1_result") do |no_result|
      expect(no_result).to have_css "td", text: "No"
      expect(no_result).to have_css "td", text: "0"
    end
  end

  it "ignores partial results from other questions" do
    other_question = create(:poll_question, poll: poll)
    create(:poll_question_option, question: other_question, title: "Yes")
    create(:poll_question_option, question: other_question, title: "Irrelevant")
    create(:poll_partial_result, question: other_question, answer: "Yes", amount: 9)
    create(:poll_partial_result, question: other_question, answer: "Irrelevant", amount: 9)

    render_inline Admin::Poll::Results::QuestionComponent.new(question, poll.partial_results)

    expect(page).to have_css "td", text: "0", count: 2
  end
end
