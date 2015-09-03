class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :load_commentable, only: :create
  before_action :build_comment, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  def create
    if @comment.save
      Mailer.comment(@comment).deliver_later if email_on_debate_comment?
      Mailer.reply(@comment).deliver_later if email_on_comment_reply?
    else
      render :new
    end
  end

  def vote
    @comment.vote_by(voter: current_user, vote: params[:value])
    respond_with @comment
  end

  def flag
    Flag.flag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: 'comments/_refresh_flag_actions'
  end

  def unflag
    Flag.unflag(current_user, @comment)
    set_comment_flags(@comment)
    respond_with @comment, template: 'comments/_refresh_flag_actions'
  end

  private

    def comment_params
      params.require(:comment).permit(:commentable_type, :commentable_id, :parent_id, :body, :as_moderator, :as_administrator)
    end

    def build_comment
      @comment = Comment.build(@commentable, current_user, comment_params[:body], comment_params[:parent_id].presence)
      check_for_special_comments
    end

    def check_for_special_comments
      if administrator_comment?
        @comment.administrator_id = current_user.administrator.id
      elsif moderator_comment?
        @comment.moderator_id = current_user.moderator.id
      end
    end

    def load_commentable
      @commentable = Comment.find_commentable(comment_params[:commentable_type], comment_params[:commentable_id])
    end

    def email_on_debate_comment?
      @comment.commentable.author.email_on_debate_comment?
    end

    def email_on_comment_reply?
      @comment.reply? && @comment.parent.author.email_on_comment_reply?
    end

    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) && can?(:comment_as_administrator, Debate)
    end

    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) && can?(:comment_as_moderator, Debate)
    end

end
