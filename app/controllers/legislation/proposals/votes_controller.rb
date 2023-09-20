module Legislation
  module Proposals
    class VotesController < ApplicationController
      before_action :authenticate_user!
      load_and_authorize_resource :process, class: "Legislation::Process"
      load_and_authorize_resource :proposal, class: "Legislation::Proposal", through: :process

      def create
        authorize! :create, Vote.new(voter: current_user, votable: @proposal)
        @proposal.vote_by(voter: current_user, vote: params[:value])

        respond_to do |format|
          format.js { render :show }
        end
      end
    end
  end
end
