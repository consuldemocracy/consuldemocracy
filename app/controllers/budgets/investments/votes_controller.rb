module Budgets
  module Investments
    class VotesController < ApplicationController
      load_and_authorize_resource :budget
      load_and_authorize_resource :investment, through: :budget, class: "Budget::Investment"

      def create
        @investment.register_selection(current_user)

        respond_to do |format|
          format.html do
            redirect_to budget_investments_path(heading_id: @investment.heading.id),
              notice: t("flash.actions.create.support")
          end

          format.js
        end
      end
    end
  end
end
