require "rails_helper"

describe "Poll Questions" do
  scenario "Lists questions from proposals before regular questions" do
    poll = create(:poll)
    normal_question = create(:poll_question, poll: poll)
    proposal_question = create(:poll_question, proposal: create(:proposal), poll: poll)

    visit poll_path(poll)

    expect(proposal_question.title).to appear_before(normal_question.title)
  end

  scenario "shows options with an image and no description" do
    poll = create(:poll)
    option = create(:poll_question_option, poll: poll, title: "Pedestrian road", description: "")
    create(:image, imageable: option, title: "Trees on both sides of the road")

    visit poll_path(poll)

    within "#poll_more_info_options" do
      expect(page).to have_content "Pedestrian road"
      expect(page).to have_css "img[alt='Trees on both sides of the road']"
    end
  end
end
