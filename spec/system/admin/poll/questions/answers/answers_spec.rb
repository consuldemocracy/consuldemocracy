require "rails_helper"

describe "Answers", :admin do
  let(:future_poll) { create(:poll, :future) }
  let(:current_poll) { create(:poll) }

  describe "Create" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)

      visit admin_question_path(question)
      click_link "Add answer"

      expect(page).to have_link "Go back", href: admin_question_path(question)

      fill_in "Answer", with: "The answer is always 42"
      fill_in_ckeditor "Description", with: "The Hitchhiker's Guide To The Universe"

      click_button "Save"

      expect(page).to have_content "Answer created successfully"
      expect(page).to have_content "The answer is always 42"
      expect(page).to have_content "The Hitchhiker's Guide To The Universe"
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)

      visit admin_question_path(question)

      expect(page).not_to have_link "Add answer"
      expect(page).to have_content "Once the poll has started it will not be possible to create, edit or"
    end

    scenario "Create second answer and place after the first one" do
      question = create(:poll_question, poll: future_poll)
      create(:poll_question_answer, title: "First", question: question, given_order: 1)

      visit admin_question_path(question)
      click_link "Add answer"

      fill_in "Answer", with: "Second"
      fill_in_ckeditor "Description", with: "Description"

      click_button "Save"

      expect("First").to appear_before("Second")
    end
  end

  scenario "Update" do
    question = create(:poll_question, poll: future_poll)
    create(:poll_question_answer, question: question, title: "Answer title", given_order: 2)
    create(:poll_question_answer, question: question, title: "Another title", given_order: 1)

    visit admin_question_path(question)
    within("tr", text: "Answer title") { click_link "Edit" }

    expect(page).to have_link "Go back", href: admin_question_path(question)

    fill_in "Answer", with: "New title"
    click_button "Save"

    expect(page).to have_content "Changes saved"
    expect(page).to have_content "New title"

    visit admin_question_path(question)

    expect(page).not_to have_content "Answer title"

    expect("Another title").to appear_before("New title")
  end

  scenario "Destroy" do
    answer = create(:poll_question_answer, poll: future_poll, title: "I'm not useful")

    visit admin_question_path(answer.question)

    within("tr", text: "I'm not useful") do
      accept_confirm("Are you sure? This action will delete \"I'm not useful\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "Answer deleted successfully"
    expect(page).not_to have_content "I'm not useful"
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
