module Api
  module V1
    class ProposalsController < ApplicationController

      before_action :authenticate_user!, except: [:index, :show]
      before_filter :load_by_pagination, :only => :index

      load_and_authorize_resource

      def index
        render :json => @proposals
      end

      def show
        render :json => @proposal
      end

      def load_by_pagination
        @proposals = Proposal.accessible_by(current_ability).page(params[:page])
      end

    end

  end
end
