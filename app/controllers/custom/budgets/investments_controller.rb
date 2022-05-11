require_dependency Rails.root.join("app", "controllers", "budgets", "investments_controller").to_s

module Budgets
  class InvestmentsController < ApplicationController
    # before_action :load_categories, only: [:index, :new, :create, :edit, :update]
    # before_action :load_budgets,  only: [:index, :new, :create, :edit, :update]

    # has_orders ->(c) { c.investments_orders }, only: :index

    # def load_budgets
    #   @budgets = Budget.where("id > -1");
    # end

    # def index
    #   @investments_count = investments.count
    #   @investments = investments.page(params[:page]).per(12).for_render
    #   @investment_ids = @investments.pluck(:id)

    #   # left over from long ago
    #   #@denied_investments = Budget::Investment.where(selected: false).page(params[:page]).per(21).for_render
    #   if @budget.phase == "finished"
    #     if @heading
    #       denied_investments = Budget::Investment.where("winner = false AND budget_id = ?",
    #         @budget.id).where("heading_id = ?", @heading.id)
    #     else
    #       denied_investments = Budget::Investment.where("winner = false AND budget_id = ?", @budget.id)
    #     end
    #   else
    #     if @heading
    #       denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
    #       .where("budget_id = ?", @budget.id).where("heading_id = ?", @heading.id)
    #     else
    #       denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
    #       .where("budget_id = ?", @budget.id)
    #     end
    #   end
    #   @denied_investments_count = denied_investments.count
    #   @denied_investments = denied_investments.page(params[:page]).per(400).for_render

    #   # unfeasible_investments = Budget::Investment.where("feasibility = ?", "unfeasible")
    #   # @unfeasible_investments_count = unfeasible_investments.count
    #   # @unfesible_investments = unfeasible_investments.page(params[:page]).per(21).for_render
    #   all_investments = Budget::Investment.where("budget_id = ?", @budget.id).order("id DESC")
    #   @all_investments_count = all_investments.count
    #   @all_investments = all_investments.page(params[:page]).per(400).for_render
    #   @all_investment_ids = @investments.pluck(:id)
    #   @tag_cloud = tag_cloud
    # end

    # def edit
    #   @investment.author = current_user
    #   @investment_ids = [@investment.id]
    # end

    # def update
    #   @investment.update!(investment_params)
    #   redirect_to budget_investment_path(@budget, @investment),
    #               notice: t("custom.titles.investment_updated")
    # end

    # def investments_orders
    #   case current_budget.phase
    #   when "accepting", "reviewing"
    #     %w[created_at]
    #   when "publishing_prices", "balloting", "reviewing_ballots"
    #     %w[created_at price]
    #   when "finished"
    #     %w[created_at]
    #   else
    #     %w[created_at confidence_score]
    #   end
    # end

    # this is so we get fields for questions on the new investment form
    def new
      @investment.budget.questions.order(:id).each do |question|
        answer = @investment.answers.build({budget_id: @investment.budget.id, budget_question_id: question.id})
      end
    end

    private

      def investment_params
        attributes = [:heading_id, :tag_list, :organization_name, :location,
                      :terms_of_service, :related_sdg_list,
                      answers_attributes: [:text, :budget_id, :investment_id, :budget_question_id],
                      image_attributes: image_attributes,
                      documents_attributes: document_attributes,
                      map_location_attributes: map_location_attributes]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

  end
end