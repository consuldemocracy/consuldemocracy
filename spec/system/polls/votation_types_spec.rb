require "rails_helper"

describe "Poll Votation Type" do
  let(:author) { create(:user, :level_two) }

  before do
    login_as(author)
  end

  scenario "Unique and multiple answers" do
    poll = create(:poll)
    create(:poll_question_unique, :yes_no, poll: poll, title: "Is it that bad?")
    create(:poll_question_multiple, :abcde, poll: poll, max_votes: 3, title: "Which ones do you prefer?")

    visit poll_path(poll)

    within_fieldset("Is it that bad?") { choose "Yes" }

    within_fieldset("Which ones do you prefer?") do
      check "Answer A"
      check "Answer C"
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

    expect(page).to have_button "Vote"
  end
end
