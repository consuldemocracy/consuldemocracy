require 'rails_helper'

feature 'Answers' do

  background do
    admin = create(:administrator)
    login_as (admin.user)
  end

  scenario 'Create' do
    question = create(:poll_question)
    title = 'Whatever the question may be, the answer is always 42'
    description = "The Hitchhiker's Guide To The Universe"

    visit admin_question_path(question)
    click_link 'Add answer'

    fill_in 'poll_question_answer_title', with: title
    fill_in 'poll_question_answer_description', with: description

    click_button 'Save'

    expect(page).to have_content(title)
    expect(page).to have_content(description)
  end

  scenario 'Update' do
    question = create(:poll_question)
    answer = create(:poll_question_answer, question: question, title: "Answer title")

    visit admin_answer_path(answer)

    click_link 'Edit'

    old_title = answer.title
    new_title = 'Ex Machina'

    fill_in 'poll_question_answer_title', with: new_title

    click_button 'Save'

    expect(page).to have_content('Changes saved')
    expect(page).to have_content(new_title)

    visit admin_question_path(question)

    expect(page).to have_content(new_title)
    expect(page).to_not have_content(old_title)
  end

end
