module Api
  module V1
    class ProposalsController < ApplicationController
      before_action :authenticate_user!, except: [:index, :show]

      load_and_authorize_resource

      def index
        @proposals = @proposals.page(params[:page])
        render :json => @proposals
      end

      def show
        render :json => @proposal
      end

    end
  end
end
