module Budgets
  class StatsController < ApplicationController

    load_and_authorize_resource :budget

    def show
      authorize! :read_stats, @budget
      @stats = load_stats
    end

    private

      def load_stats
        Budget::Stats.new(@budget).generate
      end

  end
end
