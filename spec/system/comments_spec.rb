require "rails_helper"

describe "Comments" do
  let(:factory) {
                    [
                      :budget_investment,
                      :debate,
                      :legislation_annotation,
                      :legislation_question,
                      :poll,
                      :proposal,
                      :topic_with_community,
                      :topic_with_investment_community
                    ].sample
                  }
  let(:resource) { create(factory) }
  let(:fill_text) do
    if factory == :legislation_question
      "Leave your answer"
    else
      "Leave your comment"
    end
  end

  describe "Not logged user" do
    scenario "can not see comments forms" do
      create(:comment, commentable: resource)

      visit polymorphic_path(resource)

      expect(page).to have_content "You must sign in or sign up to leave a comment"
      within("#comments") do
        expect(page).not_to have_content fill_text
        expect(page).not_to have_content "Reply"
      end
    end
  end
end
