require "rails_helper"

describe "Answers", :admin do
  let(:future_poll) { create(:poll) }
  let(:current_poll) { create(:poll, :current) }

  context "Create" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)

      visit admin_question_path(question)
      click_link "Add answer"

      fill_in "Answer", with: "The answer is always 42"
      fill_in_ckeditor "Description", with: "The Hitchhiker's Guide To The Universe"

      click_button "Save"

      expect(page).to have_content "The answer is always 42"
      expect(page).to have_content "The Hitchhiker's Guide To The Universe"
      expect(question.question_answers).not_to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)

      visit admin_question_path(question)
      click_link "Add answer"

      fill_in "Answer", with: "The answer is always 42"
      fill_in_ckeditor "Description", with: "The Hitchhiker's Guide To The Universe"

      click_button "Save"

      expect(page).to have_content "It is not possible to create answers for an already started poll."
      expect(question.question_answers).to be_empty
    end
  end

  scenario "Create second answer and place after the first one" do
    question = create(:poll_question)
    create(:poll_question_answer, title: "First", question: question, given_order: 1)

    visit admin_question_path(question)
    click_link "Add answer"

    fill_in "Answer", with: "Second"
    fill_in_ckeditor "Description", with: "Description"

    click_button "Save"

    expect("First").to appear_before("Second")
  end

  scenario "Back link goes to poll show" do
    question = create(:poll_question, poll: current_poll)

    visit admin_question_path(question)

    click_link "Go back"

    expect(page).to have_current_path(admin_poll_path(question.poll))
  end

  context "Update" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question, title: "Answer title", given_order: 2)
      create(:poll_question_answer, question: question, title: "Another title", given_order: 1)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Edit"
      end

      fill_in "Answer", with: "New title"

      click_button "Save"

      expect(page).to have_content "Changes saved"
      expect(page).to have_content "New title"

      visit admin_question_path(question)

      expect(page).not_to have_content "Answer title"

      expect("Another title").to appear_before("New title")
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question, title: "Answer title")

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Edit"
      end

      expect(page).to have_content "It is not possible to modify answers for an already started poll."

      visit admin_question_path(question)

      expect(page).to have_content "Answer title"
    end
  end

  context "Destroy" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        accept_confirm("Are you sure? This action will delete \"#{answer.title}\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).to have_content "Answer deleted succesfully"
      expect(question.question_answers).to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        accept_confirm { click_button "Delete" }
      end

      expect(page).to have_content "It is not possible to delete answers for an already started poll."
      expect(question.question_answers).not_to be_empty
    end
  end

  scenario "Reorder" do
    question = create(:poll_question)
    create(:poll_question_answer, question: question, title: "First", given_order: 1)
    create(:poll_question_answer, question: question, title: "Last", given_order: 2)

    visit admin_question_path(question)

    within("tbody.sortable") do
      expect("First").to appear_before("Last")

      find("tr", text: "Last").drag_to(find("tr", text: "First"))

      expect("Last").to appear_before("First")
    end
  end
end
