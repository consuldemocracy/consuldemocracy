class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :build_comment, only: :create
  before_action :parent, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  def create
    if @comment.save
      @comment.move_to_child_of(parent) if reply?

      Mailer.comment(@comment).deliver_now if email_on_debate_comment?
      Mailer.reply(@comment).deliver_now if email_on_comment_reply?
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
      params.require(:comment).permit(:commentable_type, :commentable_id, :body, :as_moderator, :as_administrator)
    end

    def build_comment
      @comment = Comment.build(debate, current_user, comment_params[:body])
      check_for_special_comments
    end

    def check_for_special_comments
      if administrator_comment?
        @comment.administrator_id = current_user.administrator.id
      elsif moderator_comment?
        @comment.moderator_id = current_user.moderator.id
      end
    end

    def debate
      @debate ||= Debate.find(params[:debate_id])
    end

    def parent
      @parent ||= Comment.find_parent(comment_params)
    end

    def reply?
      parent.class == Comment
    end

    def email_on_debate_comment?
      @comment.debate.author.email_on_debate_comment?
    end

    def email_on_comment_reply?
      reply? && parent.author.email_on_comment_reply?
    end

    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) && can?(:comment_as_administrator, Debate)
    end

    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) && can?(:comment_as_moderator, Debate)
    end

end
