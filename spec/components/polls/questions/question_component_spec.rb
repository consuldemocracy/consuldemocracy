require "rails_helper"

describe Polls::Questions::QuestionComponent do
  let(:poll) { create(:poll) }
  let(:question) { create(:poll_question, :yes_no, poll: poll) }
  let(:option_yes) { question.question_options.find_by(title: "Yes") }
  let(:option_no) { question.question_options.find_by(title: "No") }
  let(:user) { User.new }
  let(:web_vote) { Poll::WebVote.new(poll, user) }
  let(:form) { ConsulFormBuilder.new(:web_vote, web_vote, ApplicationController.new.view_context, {}) }

  it "renders more information links when any question option has additional information" do
    allow_any_instance_of(Poll::Question::Option).to receive(:with_read_more?).and_return(true)

    render_inline Polls::Questions::QuestionComponent.new(question, form: form)

    page.find("#poll_question_#{question.id}") do |poll_question|
      expect(poll_question).to have_content "Read more about"
      expect(poll_question).to have_link "Yes", href: "#option_#{option_yes.id}"
      expect(poll_question).to have_link "No", href: "#option_#{option_no.id}"
      expect(poll_question).to have_content "Yes, No"
    end
  end

  it "renders answers in given order" do
    render_inline Polls::Questions::QuestionComponent.new(question, form: form)

    expect("Yes").to appear_before("No")
  end

  it "renders disabled answers when given the disabled parameter" do
    render_inline Polls::Questions::QuestionComponent.new(question, form: form, disabled: true)

    page.find("fieldset[disabled]") do |fieldset|
      expect(fieldset).to have_field "Yes"
      expect(fieldset).to have_field "No"
    end
  end

  context "Verified user" do
    let(:user) { create(:user, :level_two) }
    before { sign_in(user) }

    it "renders radio buttons for single-choice questions" do
      render_inline Polls::Questions::QuestionComponent.new(question, form: form)

      expect(page).to have_field "Yes", type: :radio
      expect(page).to have_field "No", type: :radio
      expect(page).to have_field type: :radio, checked: false, count: 2
    end

    it "renders checkboxes for multiple-choice questions" do
      question = create(:poll_question_multiple, :abc, poll: poll)

      render_inline Polls::Questions::QuestionComponent.new(question, form: form)

      expect(page).to have_field "Answer A", type: :checkbox
      expect(page).to have_field "Answer B", type: :checkbox
      expect(page).to have_field "Answer C", type: :checkbox
      expect(page).to have_field type: :checkbox, checked: false, count: 3
      expect(page).not_to have_field type: :checkbox, checked: true
    end

    it "selects the option when users have already voted" do
      create(:poll_answer, author: user, question: question, option: option_yes)

      render_inline Polls::Questions::QuestionComponent.new(question, form: form)

      expect(page).to have_field "Yes", type: :radio, checked: true
      expect(page).to have_field "No", type: :radio, checked: false
    end

    context "Open-ended question" do
      let(:question) { create(:poll_question_open, poll: poll, title: "What do you want?") }
      before { create(:poll_answer, author: user, question: question, answer: "I don't know") }

      it "renders text area with persisted answer" do
        render_inline Polls::Questions::QuestionComponent.new(question, form: form)

        expect(page).to have_field "What do you want?", type: :textarea, with: "I don't know"
      end

      it "renders unsaved form text over the persisted value" do
        web_vote.answers[question.id] = [
          build(:poll_answer, question: question, author: user, answer: "Typed (unsaved)")
        ]

        render_inline Polls::Questions::QuestionComponent.new(question, form: form)

        expect(page).to have_field "What do you want?", type: :textarea, with: "Typed (unsaved)"
      end
    end
  end
end
