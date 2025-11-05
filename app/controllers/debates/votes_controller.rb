# app/controllers/debates/votes_controller.rb
module Debates
  class VotesController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :debate
    
    # Updated: Load and authorize @vote for :update as well as :destroy
    # CanCanCan will find the vote based on params[:id]
    load_and_authorize_resource through: :debate, through_association: :votes_for, only: [:destroy, :update]

    # POST /debates/:debate_id/votes
    # (Called when a user votes for the first time)
    def create
      authorize! :create, Vote.new(voter: current_user, votable: @debate)

      # Use the standard `vote_by` method from the gem.
      # It's designed to accept :vote_weight
      @debate.vote_by(
        voter: current_user,
        vote_weight: vote_params[:vote_weight],
        vote_flag: vote_params[:vote_flag]
      )

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.create.vote") }
        format.js { render :show }
      end
    end

    # PATCH /debates/:debate_id/votes/:id
    # (Called when a user *changes* their vote, e.g., from "Yes" to "No")
    def update
      # @vote is already loaded and authorized by CanCanCan
      @vote.update(vote_params)

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.update.vote") }
        format.js { render :show }
      end
    end

    # DELETE /debates/:debate_id/votes/:id
    # (Called when a user clicks an *active* button to un-vote)
    def destroy
      # @vote is already loaded and authorized.
      # Using @vote.destroy is cleaner than @debate.unvote_by
      @vote.destroy

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.destroy.vote") }
        format.js { render :show }
      end
    end

    private

    # Add strong parameters to permit the new attributes
    def vote_params
      params.require(:vote).permit(:vote_weight, :vote_flag)
    end
  end
end