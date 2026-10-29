module Legislation
  module Proposals
    class VotesController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource :process, class: "Legislation::Process"
      load_and_authorize_resource :proposal, class: "Legislation::Proposal",
                                             through: :process,
                                             id_param: "legislation_proposal_id"
      load_and_authorize_resource through: :proposal, through_association: :votes_for, only: :destroy

      def create
        authorize! :create, Vote.new(voter: current_user, votable: @proposal)
        @proposal.vote_by(voter: current_user, vote: params[:value])

        respond_to do |format|
          format.html { redirect_to request.referer, notice: I18n.t("flash.actions.create.vote") }
          format.js { render :show }
        end
      end

      def destroy
        @proposal.unvote_by(current_user)

        respond_to do |format|
          format.html { redirect_to request.referer, notice: I18n.t("flash.actions.destroy.vote") }
          format.js { render :show }
        end
      end
    end
  end
end
