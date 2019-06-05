require "rails_helper"

feature "Poll Votation Type" do

  context "Unique" do

    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:unique) { create(:poll_question_unique, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: unique, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: unique, title: "answer_2") }

    background do
      login_as(user)
    end

    scenario "response question without votation type" do
      question = create(:poll_question, :with_answers, poll: poll_current)
      visit poll_path(poll_current)

      expect(page).to have_content(question.title)
      expect(page).to have_content(answer1.title)
    end

    scenario "response question with votation type" do
      visit poll_path(poll_current)

      expect(page).to have_content(unique.title)
      expect(page).to have_content(answer1.title)
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      within("#poll_question_#{unique.id}_answers") do
        click_link answer1.title
        expect(page).to have_link(answer2.title)
        expect(page).not_to have_link(answer1.title)
      end
    end

    scenario "response question change vote", :js do
      visit poll_path(poll_current)

      within("#poll_question_#{unique.id}_answers") do
        click_link answer1.title
        expect(page).to have_link(answer2.title)
        expect(page).not_to have_link(answer1.title)
        click_link answer2.title
        expect(page).to have_link(answer1.title)
        expect(page).not_to have_link(answer2.title)
      end
    end
  end

  context "Multiple" do

    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_multiple, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: question, title: "answer_2") }
    let!(:answer3) { create(:poll_question_answer, question: question, title: "answer_3") }
    let!(:answer4) { create(:poll_question_answer, question: question, title: "answer_4") }
    let!(:answer5) { create(:poll_question_answer, question: question, title: "answer_5") }

    background do
      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
          page.find_link(answer.title).has_css?(".answered")
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        expect(page.find_link(answer6.title)).not_to have_css(".answered")
      end
    end

    scenario "response question remove vote and vote again", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      within("#poll_question_#{question.id}_answers") do
        click_link answer1.title
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        page.find_link(answer6.title).has_css?(".answered")
      end
    end
  end

  context "Prioritized" do

    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_prioritized, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: question, title: "answer_2") }
    let!(:answer3) { create(:poll_question_answer, question: question, title: "answer_3") }
    let!(:answer4) { create(:poll_question_answer, question: question, title: "answer_4") }
    let!(:answer5) { create(:poll_question_answer, question: question, title: "answer_5") }

    background do
      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
          page.find_link(answer.title).has_css?(".answered")
          page.find("span", text: answer.title).has_css?(".answered")
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        expect(page.find_link(answer6.title)).not_to have_css(".answered")
      end
    end
  end

  context "Positive open" do

    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_positive_open, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: question, title: "answer_2") }
    let!(:answer3) { create(:poll_question_answer, question: question, title: "answer_3") }
    let!(:answer4) { create(:poll_question_answer, question: question, title: "answer_4") }
    let!(:answer5) { create(:poll_question_answer, question: question, title: "answer_5") }

    background do
      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
          page.find_link(answer.title).has_css?(".answered")
        end
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        expect(page.find_link(answer6.title)).not_to have_css(".answered")
      end
    end

    scenario "response question remove vote and vote again", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      within("#poll_question_#{question.id}_answers") do
        click_link answer1.title
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        page.find_link(answer6.title).has_css?(".answered")
      end
    end

    scenario "add answer", :js do
      visit poll_path(poll_current)

      fill_in "answer", with: "added_answer"
      click_button "Add answer"

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link("added_answer")
        click_link "added_answer"
        page.find_link("added_answer").has_css?(".answered")
      end
    end
  end

  xcontext "Positive and negative open" do

    let(:user) { create(:user, :verified) }
    let(:poll_current) { create(:poll, :current) }
    let(:question) { create(:poll_question_positive_negative_open, poll: poll_current) }
    let!(:answer1) { create(:poll_question_answer, question: question, title: "answer_1") }
    let!(:answer2) { create(:poll_question_answer, question: question, title: "answer_2") }
    let!(:answer3) { create(:poll_question_answer, question: question, title: "answer_3") }
    let!(:answer4) { create(:poll_question_answer, question: question, title: "answer_4") }
    let!(:answer5) { create(:poll_question_answer, question: question, title: "answer_5") }

    background do
      login_as(user)
    end

    scenario "response question" do
      visit poll_path(poll_current)

      save_page

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          expect(page).to have_content(answer.title)
        end
      end
    end

    scenario "response question vote", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        title = "vote #{answer.title}"
        page.find("poll_question_#{question.id}_answers .in-favor a[title=#{title}]").click
        page.find("poll_question_#{question.id}_answers .in-favor a[title=#{title}]").has_css?(".answered")
      end
    end

    scenario "response question no more vote than allowed", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        expect(page.find_link(answer6.title)).not_to have_css(".answered")
      end
    end

    scenario "response question remove vote and vote again", :js do
      visit poll_path(poll_current)

      question.question_answers.each do |answer|
        within("#poll_question_#{question.id}_answers") do
          click_link answer.title
        end
      end

      within("#poll_question_#{question.id}_answers") do
        click_link answer1.title
      end

      answer6 = create(:poll_question_answer, question: question, title: "answer_6")

      visit poll_path(poll_current)

      within("#poll_question_#{question.id}_answers") do
        click_link answer6.title
        page.find_link(answer6.title).has_css?(".answered")
      end
    end

    scenario "add answer", :js do
      visit poll_path(poll_current)

      fill_in "answer", with: "added_answer"
      click_button "Add answer"

      within("#poll_question_#{question.id}_answers") do
        expect(page).to have_link("added_answer")
        click_link "added_answer"
        page.find_link("added_answer").has_css?(".answered")
      end
    end
  end


end
