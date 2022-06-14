require "rails_helper"

describe "Poll Votation Type" do
  let(:user) { create(:user, :level_two) }
  let(:poll) { create(:poll, :current) }

  before do
    login_as(user)
  end

  context "Poll question with votation type" do
    scenario "Unique answer" do
      question_unique = create(:poll_question_unique, poll: poll)

      create(:poll_question_answer, question: question_unique, title: "Answer A")
      create(:poll_question_answer, question: question_unique, title: "Answer B")

      visit poll_path(poll)

      expect(page).to have_content(question_unique.title)
      expect(page).to have_link("Answer A")
      expect(page).to have_link("Answer B")

      within "#poll_question_#{question_unique.id}_answers" do
        click_link "Answer A"

        expect(page).to have_selector("a", text: "Answer B")
        expect(page).to have_selector(".button.answered", text: "Answer A")
        expect(page).not_to have_selector("a", text: "Answer A")
      end

      within "#poll_question_#{question_unique.id}_answers" do
        click_link "Answer B"

        expect(page).to have_selector("a", text: "Answer A")
        expect(page).to have_selector(".button.answered", text: "Answer B")
        expect(page).not_to have_selector("a", text: "Answer B")
      end
    end

    scenario "Multiple answers" do
      question_multiple = create(:poll_question_multiple, poll: poll)

      create(:poll_question_answer, question: question_multiple, title: "Answer A")
      create(:poll_question_answer, question: question_multiple, title: "Answer B")
      create(:poll_question_answer, question: question_multiple, title: "Answer C")
      create(:poll_question_answer, question: question_multiple, title: "Answer D")
      create(:poll_question_answer, question: question_multiple, title: "Answer E")

      visit poll_path(poll)

      expect(page).to have_content(question_multiple.title)
      expect(page).to have_link("Answer A")
      expect(page).to have_link("Answer B")
      expect(page).to have_link("Answer C")
      expect(page).to have_link("Answer D")
      expect(page).to have_link("Answer E")

      within "#poll_question_#{question_multiple.id}_answers" do
        click_link "Answer A"
        expect(page).to have_selector("a.answered", text: "Answer A")

        click_link "Answer C"
        expect(page).to have_selector("a.answered", text: "Answer C")

        click_link "Answer E"
        expect(page).to have_selector("a.answered", text: "Answer E")

        click_link "Answer B"
        click_link "Answer D"

        expect(page).to have_selector("a", text: "Answer B")
        expect(page).to have_selector("a", text: "Answer D")
        expect(page).not_to have_selector("a.answered", text: "Answer B")
        expect(page).not_to have_selector("a.answered", text: "Answer D")
      end

      within "#poll_question_#{question_multiple.id}_answers" do
        click_link "Answer A"
        expect(page).to have_selector("a", text: "Answer A")

        click_link "Answer C"
        expect(page).to have_selector("a", text: "Answer C")

        click_link "Answer E"
        expect(page).to have_selector("a", text: "Answer E")

        click_link "Answer B"
        expect(page).to have_selector("a.answered", text: "Answer B")

        click_link "Answer D"
        expect(page).to have_selector("a.answered", text: "Answer D")

        expect(page).not_to have_selector("a.answered", text: "Answer A")
        expect(page).not_to have_selector("a.answered", text: "Answer C")
        expect(page).not_to have_selector("a.answered", text: "Answer E")
      end
    end

    scenario "Prioritized answers" do
      question_prioritized = create(:poll_question_prioritized, poll: poll)

      create(:poll_question_answer, question: question_prioritized, title: "Answer A")
      create(:poll_question_answer, question: question_prioritized, title: "Answer B")
      create(:poll_question_answer, question: question_prioritized, title: "Answer C")
      create(:poll_question_answer, question: question_prioritized, title: "Answer D")
      create(:poll_question_answer, question: question_prioritized, title: "Answer E")

      visit poll_path(poll)

      expect(page).to have_content(question_prioritized.title)
      expect(page).to have_link("Answer A")
      expect(page).to have_link("Answer B")
      expect(page).to have_link("Answer C")
      expect(page).to have_link("Answer D")
      expect(page).to have_link("Answer E")

      within("#poll_question_#{question_prioritized.id}_answers") do
        click_link "Answer A"
        expect(page).to have_selector("a.answered", text: "Answer A")

        click_link "Answer E"
        expect(page).to have_selector("a.answered", text: "Answer E")

        click_link "Answer C"
        expect(page).to have_selector("a.answered", text: "Answer C")

        click_link "Answer B"
        click_link "Answer D"
      end

      within ".ui-sortable" do
        expect(page).to have_selector("li[data-answer-id=\"Answer A\"]")
        expect(page).to have_selector("li[data-answer-id=\"Answer E\"]")
        expect(page).to have_selector("li[data-answer-id=\"Answer C\"]")

        expect("Answer A").to appear_before("Answer E")
        expect("Answer E").to appear_before("Answer C")

        expect(page).not_to have_selector("li[data-answer-id=\"Answer B\"]")
        expect(page).not_to have_selector("li[data-answer-id=\"Answer D\"]")
      end

      within("#poll_question_#{question_prioritized.id}_answers") do
        click_link "Answer A"
        expect(page).not_to have_selector("a.answered", text: "Answer A")

        click_link "Answer E"
        expect(page).not_to have_selector("a.answered", text: "Answer E")

        click_link "Answer C"
        expect(page).not_to have_selector("a.answered", text: "Answer C")
      end

      within ".ui-sortable" do
        expect(page).not_to have_selector("li")
      end

      within("#poll_question_#{question_prioritized.id}_answers") do
        click_link "Answer B"
        expect(page).to have_selector("a.answered", text: "Answer B")

        click_link "Answer D"
        expect(page).to have_selector("a.answered", text: "Answer D")
      end

      within ".ui-sortable" do
        expect(page).to have_selector("li[data-answer-id=\"Answer B\"]")
        expect(page).to have_selector("li[data-answer-id=\"Answer D\"]")

        expect("Answer B").to appear_before("Answer D")

        expect(page).not_to have_selector("li[data-answer-id=\"Answer A\"]")
        expect(page).not_to have_selector("li[data-answer-id=\"Answer C\"]")
        expect(page).not_to have_selector("li[data-answer-id=\"Answer E\"]")
      end

      find("li", text: "Answer D").drag_to(find("li", text: "Answer B"))

      within ".ui-sortable" do
        expect(page).to have_selector("li[data-answer-id=\"Answer B\"]")
        expect(page).to have_selector("li[data-answer-id=\"Answer D\"]")
        expect("Answer D").to appear_before("Answer B")
      end
    end
  end
end
