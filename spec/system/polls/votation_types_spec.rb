require "rails_helper"

describe "Poll Votation Type" do
  let(:author) { create(:user, :level_two) }
  let(:poll) { create(:poll) }

  before do
    login_as(author)
  end

  scenario "Unique, multiple and open answers" do
    create(:poll_question, :yes_no, poll: poll, title: "Is it that bad?")
    create(:poll_question_multiple, :abcde, poll: poll, max_votes: 3, title: "Which ones do you prefer?")
    create(:poll_question_open, poll: poll, title: "What do you think?")

    visit poll_path(poll)

    within_fieldset("Is it that bad?") { choose "Yes" }

    within_fieldset("Which ones do you prefer?") do
      check "Answer A"
      check "Answer C"
    end

    within(".poll-question-open-ended") do
      fill_in "What do you think?", with: "I believe it's great"
    end

    click_button "Vote"

    expect(page).to have_content "Thank you for voting!"
    expect(page).to have_content "You have already participated in this poll. " \
                                 "If you vote again it will be overwritten."

    within_fieldset("Is it that bad?") do
      expect(page).to have_field "Yes", type: :radio, checked: true
    end

    within_fieldset("Which ones do you prefer?") do
      expect(page).to have_field "Answer A", type: :checkbox, checked: true
      expect(page).to have_field "Answer B", type: :checkbox, checked: false
      expect(page).to have_field "Answer C", type: :checkbox, checked: true
      expect(page).to have_field "Answer D", type: :checkbox, checked: false
      expect(page).to have_field "Answer E", type: :checkbox, checked: false
    end

    within(".poll-question-open-ended") do
      expect(page).to have_field "What do you think?", with: "I believe it's great"
    end

    expect(page).to have_button "Vote"
  end

  scenario "Maximum votes has been reached" do
    question = create(:poll_question_multiple, :abc, poll: poll, max_votes: 2)
    create(:poll_answer, author: author, question: question, answer: "Answer A")

    visit poll_path(poll)

    expect(page).to have_field "Answer A", type: :checkbox, checked: true
    expect(page).to have_field "Answer B", type: :checkbox, checked: false
    expect(page).to have_field "Answer C", type: :checkbox, checked: false

    check "Answer C"

    expect(page).to have_field "Answer A", type: :checkbox, checked: true
    expect(page).to have_field "Answer B", type: :checkbox, checked: false, disabled: true
    expect(page).to have_field "Answer C", type: :checkbox, checked: true

    click_button "Vote"

    expect(page).to have_content "Thank you for voting!"
    expect(page).to have_field "Answer A", type: :checkbox, checked: true
    expect(page).to have_field "Answer B", type: :checkbox, checked: false, disabled: true
    expect(page).to have_field "Answer C", type: :checkbox, checked: true

    uncheck "Answer A"

    expect(page).to have_field "Answer A", type: :checkbox, checked: false
    expect(page).to have_field "Answer B", type: :checkbox, checked: false
    expect(page).to have_field "Answer C", type: :checkbox, checked: true
  end

  scenario "Too many answers", :no_js do
    create(:poll_question_multiple, :abcde, poll: poll, max_votes: 2, title: "Which ones are correct?")

    visit poll_path(poll)
    check "Answer A"
    check "Answer B"
    check "Answer D"
    click_button "Vote"

    within_fieldset("Which ones are correct?") do
      expect(page).to have_content "you've selected 3 answers, but the maximum you can select is 2"
      expect(page).to have_field "Answer A", type: :checkbox, checked: true
      expect(page).to have_field "Answer B", type: :checkbox, checked: true
      expect(page).to have_field "Answer C", type: :checkbox, checked: false
      expect(page).to have_field "Answer D", type: :checkbox, checked: true
      expect(page).to have_field "Answer E", type: :checkbox, checked: false
    end

    expect(page).not_to have_content "Thank you for voting!"

    visit poll_path(poll)

    expect(page).not_to have_content "but the maximum you can select"

    within_fieldset("Which ones are correct?") do
      expect(page).to have_field type: :checkbox, checked: false, count: 5
    end
  end
end
