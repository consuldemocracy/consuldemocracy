require "rails_helper"

describe "Poll Results" do
  scenario "List each Poll question" do
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

    poll.update_columns starts_at: 1.day.ago

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

    poll.update_columns ends_at: 1.day.ago

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

  scenario "Poll questions with multiple answers" do
    user1 = create(:user, :level_two)
    user2 = create(:user, :level_two)
    user3 = create(:user, :level_two)

    poll = create(:poll, :current, results_enabled: true)
    question = create(:poll_question_multiple, poll: poll)
    answer1 = create(:poll_question_answer, question: question, title: "Answer A")
    answer2 = create(:poll_question_answer, question: question, title: "Answer B")
    answer3 = create(:poll_question_answer, question: question, title: "Answer C")
    answer4 = create(:poll_question_answer, question: question, title: "Answer D")
    answer5 = create(:poll_question_answer, question: question, title: "Answer E")
    answer6 = create(:poll_question_answer, question: question, title: "Answer F")

    login_as user1
    visit poll_path(poll)
    vote_for_poll_multiple_via_web(poll, question, "Answer A")
    vote_for_poll_multiple_via_web(poll, question, "Answer B")
    vote_for_poll_multiple_via_web(poll, question, "Answer C")
    expect(Poll::Voter.count).to eq(1)
    logout

    login_as user2
    vote_for_poll_multiple_via_web(poll, question, "Answer C")
    vote_for_poll_multiple_via_web(poll, question, "Answer D")
    vote_for_poll_multiple_via_web(poll, question, "Answer E")
    expect(Poll::Voter.count).to eq(2)
    logout

    login_as user3
    vote_for_poll_multiple_via_web(poll, question, "Answer C")
    vote_for_poll_multiple_via_web(poll, question, "Answer B")
    expect(Poll::Voter.count).to eq(3)
    logout

    poll.update_columns ends_at: 1.day.ago

    visit results_poll_path(poll)

    expect(page).to have_content(question.title)

    within("#question_#{question.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("2 (25.0%)")
      expect(find("#answer_#{answer3.id}_result")).to have_content("3 (37.5%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (12.5%)")
      expect(find("#answer_#{answer6.id}_result")).to have_content("0 (0.0%)")
    end
  end

  scenario "Poll questions with prioritized answers" do
    user1 = create(:user, :level_two)
    user2 = create(:user, :level_two)
    user3 = create(:user, :level_two)

    poll = create(:poll, :current, results_enabled: true)
    question = create(:poll_question_prioritized, poll: poll)
    answer1 = create(:poll_question_answer, question: question, title: "Answer A")
    answer2 = create(:poll_question_answer, question: question, title: "Answer B")
    answer3 = create(:poll_question_answer, question: question, title: "Answer C")
    answer4 = create(:poll_question_answer, question: question, title: "Answer D")
    answer5 = create(:poll_question_answer, question: question, title: "Answer E")
    answer6 = create(:poll_question_answer, question: question, title: "Answer F")

    login_as user1
    visit poll_path(poll)
    vote_for_poll_multiple_via_web(poll, question, "Answer A")
    vote_for_poll_multiple_via_web(poll, question, "Answer B")
    vote_for_poll_multiple_via_web(poll, question, "Answer C")

    within ".sortable" do
      expect("Answer A").to appear_before("Answer B")
      expect("Answer B").to appear_before("Answer C")
    end

    expect(Poll::Voter.count).to eq(1)
    logout

    login_as user2
    vote_for_poll_multiple_via_web(poll, question, "Answer C")
    vote_for_poll_multiple_via_web(poll, question, "Answer D")
    vote_for_poll_multiple_via_web(poll, question, "Answer E")

    within ".sortable" do
      expect("Answer C").to appear_before("Answer D")
      expect("Answer D").to appear_before("Answer E")
    end

    expect(Poll::Voter.count).to eq(2)
    logout

    login_as user3
    vote_for_poll_multiple_via_web(poll, question, "Answer C")
    vote_for_poll_multiple_via_web(poll, question, "Answer B")

    within ".sortable" do
      expect("Answer C").to appear_before("Answer B")
    end

    expect(Poll::Voter.count).to eq(3)
    logout

    poll.update_columns ends_at: 1.day.ago

    visit results_poll_path(poll)

    expect(page).to have_content(question.title)

    within("#question_#{question.id}_results_table") do
      expect(find("#answer_#{answer1.id}_result")).to have_content("3 (17.65%)")
      expect(find("#answer_#{answer2.id}_result")).to have_content("4 (23.53%)")
      expect(find("#answer_#{answer3.id}_result")).to have_content("7 (41.18%)")
      expect(find("#answer_#{answer4.id}_result")).to have_content("2 (11.76%)")
      expect(find("#answer_#{answer5.id}_result")).to have_content("1 (5.88%)")
      expect(find("#answer_#{answer6.id}_result")).to have_content("0 (0.0%)")
    end
  end

  scenario "Results for polls with questions but without answers" do
    poll = create(:poll, :expired, results_enabled: true)
    question = create(:poll_question, poll: poll)

    visit results_poll_path(poll)

    expect(page).to have_content question.title
  end
end
