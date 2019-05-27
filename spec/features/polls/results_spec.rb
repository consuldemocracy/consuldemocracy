require "rails_helper"

feature "Poll Results" do
  scenario "List each Poll question", :js do
    user1 = create(:user, :level_two)
    user2 = create(:user, :level_two)
    user3 = create(:user, :level_two)

    poll = create(:poll, results_enabled: true)
    question1 = create(:poll_question, poll: poll)
    answer1 = create(:poll_question_answer, question: question1, title: "Yes")
    answer2 = create(:poll_question_answer, question: question1, title: "No")

    question2 = create(:poll_question, poll: poll)
    answer3 = create(:poll_question_answer, question: question2, title: "Blue")
    answer4 = create(:poll_question_answer, question: question2, title: "Green")
    answer5 = create(:poll_question_answer, question: question2, title: "Yellow")

    login_as user1
    vote_for_poll_via_web(poll, question1, "Yes")
    vote_for_poll_via_web(poll, question2, "Blue")
    expect(Poll::Voter.count).to eq(1)
    logout

    login_as user2
    vote_for_poll_via_web(poll, question1, "Yes")
    vote_for_poll_via_web(poll, question2, "Green")
    expect(Poll::Voter.count).to eq(2)
    logout

    login_as user3
    vote_for_poll_via_web(poll, question1, "No")
    vote_for_poll_via_web(poll, question2, "Yellow")
    expect(Poll::Voter.count).to eq(3)
    logout

    poll.update(ends_at: 1.day.ago)

    visit results_poll_path(poll)

    expect(page).to have_content(question1.title)
    expect(page).to have_content(question2.title)

    within("#question_#{question1.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("2 (66.67%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("1 (33.33%)")
    end

    within("#question_#{question2.id}_results_table") do
      expect(find("#answer_#{answer3.id}_result")).to have_content("1 (33.33%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("1 (33.33%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (33.33%)")
    end
  end
end
