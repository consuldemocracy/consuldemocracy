require "rails_helper"

describe "Poll Questions" do
  scenario "Lists questions from proposals before regular questions" do
    poll = create(:poll)
    normal_question = create(:poll_question, poll: poll)
    proposal_question = create(:poll_question, proposal: create(:proposal), poll: poll)

    visit poll_path(poll)

    expect(proposal_question.title).to appear_before(normal_question.title)
  end

  scenario "shows answers with an image and no description" do
    poll = create(:poll)
    answer = create(:poll_question_answer, poll: poll, title: "Pedestrian road", description: "")
    create(:image, imageable: answer, title: "Trees on both sides of the road")

    visit poll_path(poll)

    within "#poll_more_info_answers" do
      expect(page).to have_content "Pedestrian road"
      expect(page).to have_selector "img[alt='Trees on both sides of the road']"
    end
  end
end
