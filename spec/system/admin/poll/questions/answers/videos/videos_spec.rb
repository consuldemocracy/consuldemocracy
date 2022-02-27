require "rails_helper"

describe "Videos", :admin do
  let(:future_poll) { create(:poll) }
  let(:current_poll) { create(:poll, :current) }
  let(:title) { "'Magical' by Junko Ohashi" }
  let(:url) { "https://www.youtube.com/watch?v=-JMf43st-1A" }
  let(:new_title) { "Sweet Love" }
  let(:new_url) { "https://www.youtube.com/watch?v=6C4VR81GDtM" }

  context "Create" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Video list"
      end

      click_link "Add video"

      fill_in "poll_question_answer_video_title", with: title
      fill_in "poll_question_answer_video_url", with: url

      click_button "Save"

      expect(page).to have_content "Video created successfully"

      expect(answer.videos).not_to be_empty
      expect(answer.videos.first.title).to eq title
      expect(answer.videos.first.url).to eq url
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)

      visit admin_question_path(question)

      within("#poll_question_answer_#{answer.id}") do
        click_link "Video list"
      end

      click_link "Add video"

      fill_in "poll_question_answer_video_title", with: title
      fill_in "poll_question_answer_video_url", with: url

      click_button "Save"

      expect(page).to have_content "It is not possible to modify answers for an already started poll."
      expect(answer.videos).to be_empty
    end
  end

  context "Update" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      expect(video.title).to eq title
      expect(video.url).to eq url

      visit edit_admin_video_path(video)

      fill_in "poll_question_answer_video_title", with: new_title
      fill_in "poll_question_answer_video_url", with: new_url

      click_button "Save"

      expect(page).to have_content "Changes saved"

      expect(answer.videos.first.title).to eq new_title
      expect(answer.videos.first.url).to eq new_url
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      expect(video.title).to eq title
      expect(video.url).to eq url

      visit edit_admin_video_path(video)

      fill_in "poll_question_answer_video_title", with: new_title
      fill_in "poll_question_answer_video_url", with: new_url

      click_button "Save"

      expect(page).to have_content "It is not possible to modify answers for an already started poll."
      expect(answer.videos.first.title).to eq title
      expect(answer.videos.first.url).to eq url
    end
  end

  context "Destroy" do
    scenario "Is possible for a not started poll" do
      question = create(:poll_question, poll: future_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit admin_answer_videos_path(answer)

      within("#poll_question_answer_video_#{video.id}") do
        accept_confirm("Are you sure? This action will delete \"#{title}\" and can't be undone.") do
          click_button "Delete"
        end
      end

      expect(page).to have_content "Answer video deleted successfully."
      expect(answer.videos).to be_empty
    end

    scenario "Is not possible for an already started poll" do
      question = create(:poll_question, poll: current_poll)
      answer = create(:poll_question_answer, question: question)
      video = create(:poll_answer_video, answer: answer, title: title, url: url)

      visit admin_answer_videos_path(answer)

      within("#poll_question_answer_video_#{video.id}") do
        accept_confirm { click_button "Delete" }
      end

      expect(page).to have_content "It is not possible to modify answers for an already started poll."
      expect(answer.videos).not_to be_empty
    end
  end
end
