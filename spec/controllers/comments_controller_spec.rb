require "rails_helper"

describe CommentsController do

  describe "POST create" do

    let(:legal_process) { create(:legislation_process, debate_start_date: Date.current - 3.days,
                                                 debate_end_date: Date.current + 2.days) }
    let(:question) { create(:legislation_question, process: legal_process, title: "Question 1") }
    let(:user) { create(:user, :level_two) }
    let(:unverified_user) { create(:user) }

    it "creates an comment if the comments are open" do
      sign_in user

      expect do
        post :create, xhr: true,
                      params: {
                        comment: {
                          commentable_id: question.id,
                          commentable_type: "Legislation::Question",
                          body: "a comment"
                        }
                      }
      end.to change { question.reload.comments_count }.by(1)
    end

    it "does not create a comment if the comments are closed" do
      sign_in user
      legal_process.update_attribute(:debate_end_date, Date.current - 1.day)

      expect do
        post :create, xhr: true,
                      params: {
                        comment: {
                          commentable_id: question.id,
                          commentable_type: "Legislation::Question",
                          body: "a comment"
                        }
                      }
      end.not_to change { question.reload.comments_count }
    end

    it "does not create a comment for unverified users when the commentable requires it" do
      sign_in unverified_user

      expect do
        post :create, xhr: true,
                      params: {
                        comment: {
                          commentable_id: question.id,
                          commentable_type: "Legislation::Question",
                          body: "a comment"
                        }
                      }
      end.not_to change { question.reload.comments_count }
    end
  end
end
