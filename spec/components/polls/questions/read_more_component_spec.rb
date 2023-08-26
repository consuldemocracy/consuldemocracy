require "rails_helper"

describe Polls::Questions::ReadMoreComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll, title: "Question title?") }
  let(:answer) { create(:poll_question_answer, question: question) }

  it "renders question title" do
    create(:poll_question_answer, question: question, description: "Question answer description")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_content "Question title?"
  end

  it "renders answers in the given order" do
    create(:poll_question_answer, title: "Answer A", question: question, given_order: 2)
    create(:poll_question_answer, title: "Answer B", question: question, given_order: 1)

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect("Answer B").to appear_before("Answer A")
  end

  it "does not render when answers does not have more information" do
    answer.update!(description: nil)

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).not_to be_rendered
  end

  it "renders answers with videos" do
    create(:poll_answer_video, answer: answer, title: "Awesome video", url: "youtube.com/watch?v=123")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_link("Awesome video", href: "youtube.com/watch?v=123")
  end

  it "renders answers with images" do
    create(:image, imageable: answer, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_css "img[alt='The yes movement']"
  end

  it "renders answers with documents" do
    create(:document, documentable: answer, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_link("The yes movement")
  end
end
