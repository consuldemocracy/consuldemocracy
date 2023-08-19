require "rails_helper"

describe "Poll Votation Type" do
  let(:author) { create(:user, :level_two) }

  before do
    login_as(author)
  end

  scenario "Unique answer" do
    question = create(:poll_question_unique, :yes_no)

    visit poll_path(question.poll)

    expect(page).to have_content "You can select a maximum of 1 answer."
    expect(page).to have_content(question.title)
    expect(page).to have_button("Vote Yes")
    expect(page).to have_button("Vote No")

    within "#poll_question_#{question.id}_answers" do
      click_button "Yes"

      expect(page).to have_button("You have voted Yes")
      expect(page).to have_button("Vote No")

      click_button "No"

      expect(page).to have_button("Vote Yes")
      expect(page).to have_button("You have voted No")
    end
  end

  scenario "Multiple answers" do
    question = create(:poll_question_multiple, :abc, max_votes: 2)
    visit poll_path(question.poll)

    expect(page).to have_content "You can select a maximum of 2 answers."
    expect(page).to have_content(question.title)
    expect(page).to have_button("Vote Answer A")
    expect(page).to have_button("Vote Answer B")
    expect(page).to have_button("Vote Answer C")

    within "#poll_question_#{question.id}_answers" do
      click_button "Vote Answer A"

      expect(page).to have_button("You have voted Answer A")

      click_button "Vote Answer C"

      expect(page).to have_button("You have voted Answer C")
      expect(page).to have_button("Vote Answer B", disabled: true)

      click_button "You have voted Answer A"

      expect(page).to have_button("Vote Answer A")
      expect(page).to have_button("Vote Answer B")

      click_button "You have voted Answer C"

      expect(page).to have_button("Vote Answer C")

      click_button "Vote Answer B"

      expect(page).to have_button("You have voted Answer B")
      expect(page).to have_button("Vote Answer A")
      expect(page).to have_button("Vote Answer C")
    end
  end
end
