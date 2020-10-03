module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :authenticate_user!
      before_action :load_budget
      before_action :load_ballot
      before_action :load_tag_cloud
      before_action :load_categories
      before_action :load_investments
      before_action :load_ballot_referer

      authorize_resource :budget
      authorize_resource :ballot
      load_and_authorize_resource :line, through: :ballot, find_by: :investment_id, class: "Budget::Ballot::Line"

      def create
        load_investment
        load_heading
        load_map

        @ballot.add_investment(@investment)
      end

      def destroy
        @investment = @line.investment
        load_heading
        load_map

        @line.destroy!
        load_investments
      end

      private

        def line_params
          params.permit(:investment_id, :budget_id)
        end

        def load_budget
          @budget = Budget.find_by_slug_or_id! params[:budget_id]
        end

        def load_ballot
          @ballot = Budget::Ballot.where(user: current_user, budget: @budget).first_or_create!
        end

        def load_investment
          @investment = Budget::Investment.find(params[:investment_id])
        end

        def load_investments
          if params[:investments_ids].present?
            @investment_ids = params[:investments_ids]
            @investments = Budget::Investment.where(id: params[:investments_ids])
          end
        end

        def load_heading
          @heading = @investment.heading
        end

        def load_tag_cloud
          @tag_cloud = TagCloud.new(Budget::Investment, params[:search])
        end

        def load_categories
          @categories = Tag.category.order(:name)
        end

        def load_ballot_referer
          @ballot_referer = session[:ballot_referer]
        end

        def load_map
          @investments ||= []
          @investments_map_coordinates = MapLocation.where(investment: @investments).map(&:json_data)
          @map_location = MapLocation.load_from_heading(@heading)
        end
    end
  end
end
