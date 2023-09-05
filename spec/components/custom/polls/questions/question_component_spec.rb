require "rails_helper"

describe Polls::Questions::QuestionComponent do
  it "renders more information links when any question answer has additional information" do
    question = create(:poll_question)
    questions = [question]
    index = 0
    answer_a = create(:poll_question_answer, question: question, title: "Answer A")
    answer_b = create(:poll_question_answer, question: question, title: "Answer B")
    allow_any_instance_of(Poll::Question::Answer).to receive(:with_read_more?).and_return(true)

    render_inline Polls::Questions::QuestionComponent.new(questions, question, index)

    poll_question = page.find("#poll_question_#{question.id}")
    expect(poll_question).to have_content("Read more about")
    expect(poll_question).to have_link("Answer A", href: "#answer_#{answer_a.id}")
    expect(poll_question).to have_link("Answer B", href: "#answer_#{answer_b.id}")
    expect(poll_question).to have_content("Answer A, Answer B")
  end
end
