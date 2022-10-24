class CommentsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :hide, :vote]
  before_action :load_commentable, only: :create
  before_action :verify_resident_for_commentable!, only: :create
  before_action :verify_comments_open!, only: [:create, :vote]
  before_action :build_comment, only: :create

  load_and_authorize_resource
  respond_to :html, :js

  def create
    if @comment.save
      CommentNotifier.new(comment: @comment).process
      add_notification @comment
      EvaluationCommentNotifier.new(comment: @comment).process if send_evaluation_notification?
    else
      render :new
    end
  end

  def show
    @comment = Comment.find(params[:id])
    if @comment.valuation && @comment.author != current_user
      raise ActiveRecord::RecordNotFound
    else
      set_comment_flags(@comment.subtree)
    end
  end

  def vote
    @comment.vote_by(voter: current_user, vote: params[:value])
    respond_with @comment
  end

  def flag
    Flag.flag(current_user, @comment)
    set_comment_flags(@comment)

    render "shared/_refresh_flag_actions", locals: { flaggable: @comment, divider: true }
  end

  def unflag
    Flag.unflag(current_user, @comment)
    set_comment_flags(@comment)

    render "shared/_refresh_flag_actions", locals: { flaggable: @comment, divider: true }
  end

  def hide
    @comment.hide
    set_comment_flags(@comment.subtree)
  end

  private

    def comment_params
      params.require(:comment).permit(allowed_params)
    end

    def allowed_params
      [
        :commentable_type, :commentable_id, :parent_id,
        :body, :as_moderator, :as_administrator, :valuation
      ]
    end

    def build_comment
      @comment = Comment.build(@commentable, current_user, comment_params[:body],
                               comment_params[:parent_id].presence,
                               comment_params[:valuation])
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
      @commentable = Comment.find_commentable(comment_params[:commentable_type],
                                              comment_params[:commentable_id])
    end

    def administrator_comment?
      ["1", true].include?(comment_params[:as_administrator]) &&
        can?(:comment_as_administrator, @commentable)
    end

    def moderator_comment?
      ["1", true].include?(comment_params[:as_moderator]) &&
        can?(:comment_as_moderator, @commentable)
    end

    def add_notification(comment)
      notifiable = comment.reply? ? comment.parent : comment.commentable
      notifiable_author_id = notifiable&.author_id
      if notifiable_author_id.present? && notifiable_author_id != comment.author_id
        Notification.add(notifiable.author, notifiable)
      end
    end

    def verify_resident_for_commentable!
      return if current_user.administrator? || current_user.moderator?

      if @commentable.respond_to?(:comments_for_verified_residents_only?) &&
         @commentable.comments_for_verified_residents_only?
        verify_resident!
      end
    end

    def verify_comments_open!
      return if current_user.administrator? || current_user.moderator?

      if @commentable.respond_to?(:comments_closed?) && @commentable.comments_closed?
        redirect_to polymorphic_path(@commentable), alert: t("comments.comments_closed")
      end
    end

    def send_evaluation_notification?
      @comment.valuation && Setting["feature.valuation_comment_notification"]
    end
end
