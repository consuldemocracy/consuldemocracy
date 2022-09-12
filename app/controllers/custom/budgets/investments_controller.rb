require_dependency Rails.root.join("app", "controllers", "budgets", "investments_controller").to_s

module Budgets
  class InvestmentsController < ApplicationController
    before_action :load_follow, only: :show

    private

      def load_follow
        @follow = Follow.find_or_initialize_by(user: current_user, followable: @investment)
      end
  end
end
