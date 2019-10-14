require 'rails_helper'

describe CommentsController do

  describe 'POST create' do
    before(:each) do
      @process = create(:legislation_process, debate_start_date: Date.current - 3.day, debate_end_date: Date.current + 2.days)
      @question = create(:legislation_question, process: @process, title: "Question 1")
      @user = create(:user, :level_two)
      @unverified_user = create(:user)
    end

    it 'should create an comment if the comments are open' do
      sign_in @user

      expect do
        xhr :post, :create, comment: {commentable_id: @question.id, commentable_type: "Legislation::Question", body: "a comment"}
      end.to change { @question.reload.comments_count }.by(1)
    end

    it 'should not create a comment if the comments are closed' do
      sign_in @user
      @process.update_attribute(:debate_end_date, Date.current - 1.day)

      expect do
        xhr :post, :create, comment: {commentable_id: @question.id, commentable_type: "Legislation::Question", body: "a comment"}
      end.to_not change { @question.reload.comments_count }
    end

    it 'should not create a comment for unverified users when the commentable requires it' do
      sign_in @unverified_user

      expect do
        xhr :post, :create, comment: {commentable_id: @question.id, commentable_type: "Legislation::Question", body: "a comment"}
      end.to_not change { @question.reload.comments_count }
    end
  end
end
