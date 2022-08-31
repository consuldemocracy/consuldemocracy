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
  end

  it "renders a span instead of a button for existing user answers" do
    user = create(:user, :verified)
    allow(user).to receive(:current_sign_in_at).and_return(user.created_at)
    create(:poll_answer, author: user, question: question, answer: "Yes")
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector "span", text: "Yes"
    expect(page).not_to have_button "Yes"
    expect(page).to have_button "No"
  end

  it "hides current answer and shows buttons in successive sessions" do
    user = create(:user, :verified)
    create(:poll_answer, author: user, question: question, answer: "Yes")
    allow(user).to receive(:current_sign_in_at).and_return(Time.current)
    sign_in(user)

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_button "Yes"
    expect(page).to have_button "No"
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

    expect(page).to have_selector "span.disabled", text: "Yes"
    expect(page).to have_selector "span.disabled", text: "No"
  end

  it "user cannot vote when poll expired it renders disabled answers" do
    question = create(:poll_question, :yes_no, poll: create(:poll, :expired))
    sign_in(create(:user, :level_two))

    render_inline Polls::Questions::AnswersComponent.new(question)

    expect(page).to have_selector "span.disabled", text: "Yes"
    expect(page).to have_selector "span.disabled", text: "No"
  end

  describe "geozone" do
    let(:poll) { create(:poll, geozone_restricted: true) }
    let(:geozone) { create(:geozone) }
    let(:question) { create(:poll_question, :yes_no, poll: poll) }

    it "when geozone which is not theirs it renders disabled answers" do
      poll.geozones << geozone
      sign_in(create(:user, :level_two))

      render_inline Polls::Questions::AnswersComponent.new(question)

      expect(page).to have_selector "span.disabled", text: "Yes"
      expect(page).to have_selector "span.disabled", text: "No"
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
