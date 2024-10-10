require "rails_helper"

describe Polls::Questions::QuestionComponent do
  it "renders more information links when any question option has additional information" do
    question = create(:poll_question)
    option_a = create(:poll_question_option, question: question, title: "Answer A")
    option_b = create(:poll_question_option, question: question, title: "Answer B")
    allow_any_instance_of(Poll::Question::Option).to receive(:with_read_more?).and_return(true)

    render_inline Polls::Questions::QuestionComponent.new(question: question)

    poll_question = page.find("#poll_question_#{question.id}")
    expect(poll_question).to have_content("Read more about")
    expect(poll_question).to have_link("Answer A", href: "#option_#{option_a.id}")
    expect(poll_question).to have_link("Answer B", href: "#option_#{option_b.id}")
    expect(poll_question).to have_content("Answer A, Answer B")
  end
end
