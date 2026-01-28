# app/controllers/debates/votes_controller.rb
module Debates
  class VotesController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :debate

    load_and_authorize_resource through: :debate, through_association: :votes_for, only: [:destroy, :update]

    def create
      authorize! :create, Vote.new(voter: current_user, votable: @debate)

      @debate.register_vote(current_user, vote_params)

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.create.vote") }
        format.js { render :show }
      end
    end

    def update
      @vote.update!(vote_params)

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.update.vote") }
        format.js { render :show }
      end
    end

    def destroy
      @vote.destroy!

      respond_to do |format|
        format.html { redirect_to request.referer, notice: I18n.t("flash.actions.destroy.vote") }
        format.js { render :show }
      end
    end

    private

      def vote_params
        params.require(:vote).permit(:vote_weight, :vote_flag)
      end
  end
end
