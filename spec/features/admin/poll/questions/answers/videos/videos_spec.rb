require 'rails_helper'

feature 'Videos' do

  background do
    admin = create(:administrator)
    login_as(admin.user)
  end

  scenario "Create" do
    question = create(:poll_question)
    answer = create(:poll_question_answer, question: question)
    video_title = "'Magical' by Junko Ohashi"
    video_url = "https://www.youtube.com/watch?v=-JMf43st-1A"

    visit admin_question_path(question)

    within("#poll_question_answer_#{answer.id}") do
      click_link "Video list"
    end

    click_link "Add video"

    fill_in 'poll_question_answer_video_title', with: video_title
    fill_in 'poll_question_answer_video_url', with: video_url

    click_button "Save"

    expect(page).to have_content(video_title)
    expect(page).to have_content(video_url)
  end

end
