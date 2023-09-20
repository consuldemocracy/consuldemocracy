module Comments
  class VotesController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :comment
    load_and_authorize_resource through: :comment, through_association: :votes_for, only: :destroy
    before_action :verify_comments_open!

    def create
      authorize! :create, Vote.new(voter: current_user, votable: @comment)
      @comment.vote_by(voter: current_user, vote: params[:value])

      respond_to do |format|
        format.js { render :show }
      end
    end

    def destroy
      @comment.unvote_by(current_user)

      respond_to do |format|
        format.js { render :show }
      end
    end

    private

      def verify_comments_open!
        return if current_user.administrator? || current_user.moderator?

        if @comment.commentable.respond_to?(:comments_closed?) && @comment.commentable.comments_closed?
          redirect_to polymorphic_path(@comment.commentable), alert: t("comments.comments_closed")
        end
      end
  end
end
