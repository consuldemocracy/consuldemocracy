module Budgets
  class BallotsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :budget
    before_action :load_ballot

    def show
      authorize! :show, @ballot
      render template: "budgets/ballot/show"
    end

    private

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
      end

  end
end
