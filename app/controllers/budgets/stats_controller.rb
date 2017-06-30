module Budgets
  class StatsController < ApplicationController

    before_action :load_budget
    load_and_authorize_resource :budget

    def show
      authorize! :read_stats, @budget
      @stats = load_stats
    end

    private

      def load_stats
        Budget::Stats.new(@budget).generate
      end

      def load_budget
        @budget = Budget.find_by(slug: params[:id]) || Budget.find_by(id: params[:id])
      end

  end
end
