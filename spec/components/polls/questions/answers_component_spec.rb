require "rails_helper"

describe Polls::Questions::AnswersComponent do
  include Rails.application.routes.url_helpers
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, :yes_no, poll: poll) }

  it "renders answers in given order" do
    render_inline Polls::Questions::AnswersComponent.new(question)

    expect("Yes").to appear_before("No")
  end

  it "renders buttons to vote question answers" do
    sign_in(create(:user, :verified))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
    expect(page).to have_css "button[aria-pressed='false']", count: 2
  end

  it "renders button to destroy current user answers" do
    user = create(:user, :verified)
    create(:poll_answer, author: user, question: question, answer: "Yes")
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "You have voted Yes"
    expect(page).to have_button "Vote No"
    expect(page).to have_css "button[aria-pressed='true']", text: "Yes"
  end

  it "renders disabled buttons when max votes is reached" do
    user = create(:user, :verified)
    question = create(:poll_question_multiple, :abc, max_votes: 2, author: user)
    create(:poll_answer, author: user, question: question, answer: "Answer A")
    create(:poll_answer, author: user, question: question, answer: "Answer C")
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "You have voted Answer A"
    expect(page).to have_button "Vote Answer B", disabled: true
    expect(page).to have_button "You have voted Answer C"
  end

  it "when user is not signed in, renders answers links pointing to user sign in path" do
    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Yes", href: new_user_session_path
    expect(page).to have_link "No", href: new_user_session_path
  end

  it "when user is not verified, renders answers links pointing to user verification in path" do
    sign_in(create(:user))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_link "Yes", href: verification_path
    expect(page).to have_link "No", href: verification_path
  end

  it "when user already voted in booth it renders disabled answers" do
    user = create(:user, :level_two)
    create(:poll_voter, :from_booth, poll: poll, user: user)
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_css "span.disabled", text: "Yes"
    expect(page).to have_css "span.disabled", text: "No"
  end

  it "user cannot vote when poll expired it renders disabled answers" do
    question = create(:poll_question, :yes_no, poll: create(:poll, :expired))
    sign_in(create(:user, :level_two))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_css "span.disabled", text: "Yes"
    expect(page).to have_css "span.disabled", text: "No"
  end

  describe "geozone" do
    let(:poll) { create(:poll, geozone_restricted: true) }
    let(:geozone) { create(:geozone) }
    let(:question) { create(:poll_question, :yes_no, poll: poll) }

    it "when geozone which is not theirs it renders disabled answers" do
      poll.geozones << geozone
      sign_in(create(:user, :level_two))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_css "span.disabled", text: "Yes"
      expect(page).to have_css "span.disabled", text: "No"
    end

    it "reading a same-geozone poll it renders buttons to vote question answers" do
      poll.geozones << geozone
      sign_in(create(:user, :level_two, geozone: geozone))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_button "Yes"
      expect(page).to have_button "No"
    end
  end
end
