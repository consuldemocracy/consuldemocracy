require "rails_helper"

describe "Commenting legislation questions" do
  let(:user) { create(:user, :level_two) }
  let(:process) { create(:legislation_process, :in_debate_phase) }
  let(:question) { create(:legislation_question, process: process) }

  context "Concerns" do
    it_behaves_like "notifiable in-app", :legislation_question
    it_behaves_like "flaggable", :legislation_question_comment
  end

  scenario "Submit button is disabled after clicking" do
    login_as(user)
    visit legislation_process_question_path(question.process, question)

    fill_in "Leave your answer", with: "Testing submit button!"
    click_button "Publish answer"

    expect(page).to have_button "Publish answer", disabled: true
    expect(page).to have_content "Testing submit button!"
    expect(page).to have_button "Publish answer", disabled: false
  end

  describe "Voting comments" do
    let(:verified)   { create(:user, verified_at: Time.current) }
    let(:unverified) { create(:user) }
    let(:question)   { create(:legislation_question) }
    let!(:comment)   { create(:comment, commentable: question) }

    before do
      login_as(verified)
    end

    scenario "Update" do
      visit legislation_process_question_path(question.process, question)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"

        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I disagree"

        within(".in-favor") do
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "1"
        end

        expect(page).to have_content "1 vote"
      end
    end

    scenario "Allow undoing votes" do
      visit legislation_process_question_path(question.process, question)

      within("#comment_#{comment.id}_votes") do
        click_button "I agree"
        within(".in-favor") do
          expect(page).to have_content "1"
        end

        click_button "I agree"
        within(".in-favor") do
          expect(page).not_to have_content "2"
          expect(page).to have_content "0"
        end

        within(".against") do
          expect(page).to have_content "0"
        end

        expect(page).to have_content "No votes"
      end
    end
  end
end
