require "rails_helper"

describe Polls::Questions::ReadMoreAnswerComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll) }
  let(:answer) { create(:poll_question_answer, question: question) }

  it "renders answers with videos" do
    create(:poll_answer_video, answer: answer, title: "Awesome video", url: "youtube.com/watch?v=123")

    render_inline Polls::Questions::ReadMoreAnswerComponent.new(answer: answer)

    expect(page).to have_link("Awesome video", href: "youtube.com/watch?v=123")
  end

  it "renders answers with images" do
    create(:image, imageable: answer, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreAnswerComponent.new(answer: answer)

    expect(page).to have_css "img[alt='The yes movement']"
  end

  it "renders answers with documents" do
    create(:document, documentable: answer, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreAnswerComponent.new(answer: answer)

    expect(page).to have_link("The yes movement")
  end
end
