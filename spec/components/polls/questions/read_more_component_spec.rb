require "rails_helper"

describe Polls::Questions::ReadMoreComponent do
  include Rails.application.routes.url_helpers

  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, poll: poll, title: "Question title?") }
  let(:option) { create(:poll_question_option, question: question) }

  it "renders question title" do
    create(:poll_question_option, question: question, description: "Question option description")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_content "Question title?"
  end

  it "renders options in the given order" do
    create(:poll_question_option, title: "Answer A", question: question, given_order: 2)
    create(:poll_question_option, title: "Answer B", question: question, given_order: 1)

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect("Answer B").to appear_before("Answer A")
  end

  it "does not render when options does not have more information" do
    option.update!(description: nil)

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).not_to be_rendered
  end

  it "renders options with videos" do
    create(:poll_option_video, option: option, title: "Awesome video", url: "youtube.com/watch?v=123")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_link("Awesome video", href: "youtube.com/watch?v=123")
  end

  it "renders options with images" do
    create(:image, imageable: option, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_css "img[alt='The yes movement']"
  end

  it "renders options with documents" do
    create(:document, documentable: option, title: "The yes movement")

    render_inline Polls::Questions::ReadMoreComponent.new(question: question)

    expect(page).to have_link text: "The yes movement"
  end
end
