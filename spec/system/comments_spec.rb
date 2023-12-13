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
  let(:user) do
    if factory == :legislation_question
      create(:user, :level_two)
    else
      create(:user)
    end
  end
  let(:fill_text) do
    if factory == :legislation_question
      "Leave your answer"
    else
      "Leave your comment"
    end
  end
  let(:button_text) do
    if factory == :legislation_question
      "Publish answer"
    else
      "Publish comment"
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

  scenario "Errors on create" do
    login_as(user)
    visit polymorphic_path(resource)

    click_button button_text

    expect(page).to have_content "Can't be blank"
  end
end
