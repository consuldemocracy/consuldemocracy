module Budgets
  class BallotsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :budget
    before_action :load_ballot

    def show
      render template: "budgets/ballot/show"
    end

    private

      def load_ballot
        @ballot = Budget::Ballot.where(user: current_user, budget: @budget).first_or_create
      end

  end
end