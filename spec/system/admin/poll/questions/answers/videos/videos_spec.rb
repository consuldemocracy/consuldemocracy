require "rails_helper"

describe "Videos", :admin do
  let!(:question) { create(:poll_question) }
  let!(:answer) { create(:poll_question_answer, question: question) }
  let(:title) { "'Magical' by Junko Ohashi" }
  let(:url) { "https://www.youtube.com/watch?v=-JMf43st-1A" }

  scenario "Create" do
    visit admin_question_path(question)

    within("#poll_question_answer_#{answer.id}") do
      click_link "Video list"
    end
    click_link "Add video"

    fill_in "Title", with: title
    fill_in "External video", with: url

    click_button "Save"

    expect(page).to have_content title
    expect(page).to have_content url
  end

  scenario "Update" do
    video = create(:poll_answer_video, answer: answer)

    visit edit_admin_answer_video_path(answer, video)

    expect(page).to have_link "Go back", href: admin_answer_videos_path(answer)

    fill_in "Title", with: title
    fill_in "External video", with: url

    click_button "Save"

    expect(page).to have_content title
    expect(page).to have_content url
  end

  scenario "Destroy" do
    video = create(:poll_answer_video, answer: answer)

    visit admin_answer_videos_path(answer)

    within("#poll_question_answer_video_#{video.id}") do
      accept_confirm("Are you sure? This action will delete \"#{video.title}\" and can't be undone.") do
        click_button "Delete"
      end
    end

    expect(page).to have_content "Answer video deleted successfully."
  end
end
