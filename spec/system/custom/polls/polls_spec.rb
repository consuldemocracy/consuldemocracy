require "rails_helper"

describe "Polls" do
  describe "Index" do
    scenario "Polls display list of questions" do
      poll = create(:poll, :with_image)
      question1 = create(:poll_question, :yes_no, poll: poll)
      question2 = create(:poll_question, :yes_no, poll: poll)

      visit polls_path

      expect(page).to have_content(poll.name)
      expect(page).to have_content("Question 1 #{question1.title}")
      expect(page).to have_content("Question 2 #{question2.title}")
    end

    scenario "Polls display remaining days to participate if not expired" do
      create(:poll, starts_at: Time.current, ends_at: 11.days.from_now)
      create(:poll, :expired)

      visit polls_path

      within(".poll") do
        expect(page).to have_content("Remaining 11 days to participate")
      end

      click_link "Expired"

      within(".poll") do
        expect(page).not_to have_content("Remaining")
        expect(page).not_to have_content("days to participate")
      end
    end

    scenario "Polls display remaining hours to participate if not expired" do
      create(:poll, starts_at: Time.current, ends_at: 8.hours.from_now)
      create(:poll, :expired)

      visit polls_path

      within(".poll") do
        expect(page).to have_content("Remaining about 8 hours to participate")
      end

      click_link "Expired"

      within(".poll") do
        expect(page).not_to have_content("Remaining")
        expect(page).not_to have_content("days to participate")
      end
    end

    scenario "Expired polls are ordered by ends date" do
      travel_to "01/07/2023".to_date do
        create(:poll, starts_at: "03/05/2023", ends_at: "01/06/2023", name: "Expired poll one")
        create(:poll, starts_at: "02/05/2023", ends_at: "02/06/2023", name: "Expired poll two")
        create(:poll, starts_at: "01/05/2023", ends_at: "03/06/2023", name: "Expired poll three")
        create(:poll, starts_at: "04/05/2023", ends_at: "04/06/2023", name: "Expired poll four")
        create(:poll, starts_at: "05/05/2023", ends_at: "05/06/2023", name: "Expired poll five")

        visit polls_path(filter: "expired")

        expect("Expired poll five").to appear_before("Expired poll four")
        expect("Expired poll four").to appear_before("Expired poll three")
        expect("Expired poll three").to appear_before("Expired poll two")
        expect("Expired poll two").to appear_before("Expired poll one")
      end
    end
  end

  context "Show" do
    let(:geozone) { create(:geozone) }
    let(:poll) { create(:poll, summary: "Summary", description: "Description") }

    scenario "Lists questions from proposals as well as regular ones" do
      normal_question = create(:poll_question, poll: poll)
      proposal_question = create(:poll_question, poll: poll, proposal: create(:proposal))

      visit poll_path(poll)
      expect(page).to have_content(poll.name)
      expect(page).to have_content(poll.summary)

      expect(page).to have_content("Question 1 #{proposal_question.title}", normalize_ws: true)
      expect(page).to have_content("Question 2 #{normal_question.title}", normalize_ws: true)

      find("#read_more").click
      expect(page).to have_content(poll.description)

      find("#read_less").click
      expect(page).not_to have_content(poll.description)
    end

    scenario "Do not show question number in polls with one question" do
      question = create(:poll_question, poll: poll)

      visit poll_path(poll)

      expect(page).to have_content question.title
      expect(page).not_to have_content("Question 1")
    end

    scenario "Question appear by created at order" do
      question = create(:poll_question, poll: poll, title: "First question")
      create(:poll_question, poll: poll, title: "Second question")
      question_3 = create(:poll_question, poll: poll, title: "Third question")

      visit polls_path
      expect("First question").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      visit poll_path(poll)

      expect("First question").to appear_before("Second question")
      expect("Second question").to appear_before("Third question")

      question_3.update!(title: "Third question edited")
      question.update!(title: "First question edited")

      visit polls_path
      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question edited")

      visit poll_path(poll)

      expect("First question edited").to appear_before("Second question")
      expect("Second question").to appear_before("Third question edited")
    end

    scenario "Read more button appears only in long answer descriptions" do
      question = create(:poll_question, poll: poll)
      answer_long = create(:poll_question_answer, title: "Long answer", question: question,
                           description: Faker::Lorem.characters(number: 700))
      create(:poll_question_answer, title: "Short answer", question: question,
             description: Faker::Lorem.characters(number: 100))

      visit poll_path(poll)

      expect(page).to have_content "Long answer"
      expect(page).to have_content "Short answer"
      expect(page).to have_css "#answer_description_#{answer_long.id}.answer-description.short"

      within "#poll_more_info_answers" do
        expect(page).to have_content "Read more about Long answer"
        expect(page).not_to have_content "Read more about Short answer"
      end

      find("#read_more_#{answer_long.id}").click

      expect(page).to have_content "Read less about Long answer"
      expect(page).to have_css "#answer_description_#{answer_long.id}.answer-description"
      expect(page).not_to have_css "#answer_description_#{answer_long.id}.answer-description.short"

      find("#read_less_#{answer_long.id}").click

      expect(page).to have_content "Read more about Long answer"
      expect(page).to have_css "#answer_description_#{answer_long.id}.answer-description.short"
    end

    scenario "Show orbit bullets and controls only when there is more than one image" do
      poll = create(:poll)
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "Answer with one image", question: question)
      answer2 = create(:poll_question_answer, title: "Answer with two images", question: question)
      create(:image, imageable: answer1)
      create(:image, imageable: answer2)
      create(:image, imageable: answer2)

      visit poll_path(poll)

      within("#answer_#{answer1.id}_gallery") do
        expect(page).not_to have_css ".orbit-controls"
        expect(page).not_to have_css "nav.orbit-bullets"
      end

      within("#answer_#{answer2.id}_gallery") do
        expect(page).to have_css ".orbit-controls"
        expect(page).to have_css "nav.orbit-bullets"
      end
    end

    scenario "Question answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div#poll_question_#{question.id}") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "More info answers appear in the given order" do
      question = create(:poll_question, poll: poll)
      answer1 = create(:poll_question_answer, title: "First", question: question, given_order: 2)
      answer2 = create(:poll_question_answer, title: "Second", question: question, given_order: 1)

      visit poll_path(poll)

      within("div.poll-more-info-answers") do
        expect(answer2.title).to appear_before(answer1.title)
      end
    end

    scenario "Answer images are shown" do
      question = create(:poll_question, :yes_no, poll: poll)
      create(:image, imageable: question.question_answers.first, title: "The yes movement")

      visit poll_path(poll)

      expect(page).to have_css "img[alt='The yes movement']"
    end
  end
end
