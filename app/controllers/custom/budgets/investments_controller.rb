require_dependency Rails.root.join("app", "controllers", "budgets", "investments_controller").to_s

module Budgets
  class InvestmentsController < ApplicationController
    PER_PAGE = 12
    before_action :load_categories, only: [:index, :new, :create, :edit, :update]
    # before_action :load_budgets,  only: [:index, :new, :create, :edit, :update]

    # has_orders ->(c) { c.investments_orders }, only: :index

    # def load_budgets
    #   @budgets = Budget.where("id > -1");
    # end

    def load_categories
      @categories = Tag.category.order(:name)
    end

    def index
      # filters
      if params[:unfeasible]
        winner_ids = []
        winners = @budget.investments.winners.order(:id).each do |investment|
          winner_ids.push(investment.id)
        end
        puts winner_ids
        puts "ASDASDASDASD"
        if params[:heading_id]
          feasibility_filtered_investments = @budget.investments.where(heading_id: params[:heading_id]).where.not(:id => winner_ids)
        else
          feasibility_filtered_investments = @budget.investments.where.not(:id => winner_ids)
        end
      else
        feasibility_filtered_investments = investments
      end
      if params[:status_id]
        investment_ids = []
        Budget::Investment.all.order(:id).each do |investment|
          if investment.milestones.count > 0
            if investment.milestones.order_by_publication_date.last.status_id == params[:status_id].to_i
              investment_ids.push(investment.id)
            end
          end
        end
        filtered_investments = feasibility_filtered_investments.where(id: investment_ids)
      else
        filtered_investments = feasibility_filtered_investments
      end
      if params[:tag_name]
        tagged_investments = filtered_investments.tagged_with(params[:tag_name])
      else
        tagged_investments = filtered_investments
      end

      @filtered_investments_count = tagged_investments.count
      @investments = tagged_investments.page(params[:page]).per(PER_PAGE).for_render
      @statuses = Milestone::Status.all

      @investment_ids = @investments.ids
      @investments_map_coordinates = MapLocation.where(investment: investments).map(&:json_data)

      @tag_cloud = tag_cloud
      @remote_translations = detect_remote_translations(@investments)
    #   @investments_count = investments.count
    #   @investments = investments.page(params[:page]).per(12).for_render
    #   @investment_ids = @investments.pluck(:id)

      #@denied_investments = Budget::Investment.where(selected: false).page(params[:page]).per(21).for_render
      if @budget.phase == "finished"
        if @heading
          denied_investments = Budget::Investment.where("winner = false AND budget_id = ?",
            @budget.id).where("heading_id = ?", @heading.id)
        else
          denied_investments = Budget::Investment.where("winner = false AND budget_id = ?", @budget.id)
        end
      else
        if @heading
          denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
          .where("budget_id = ?", @budget.id).where("heading_id = ?", @heading.id)
        else
          denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
          .where("budget_id = ?", @budget.id)
        end
      end
      @denied_investments_count = denied_investments.count
      @denied_investments = denied_investments.page(params[:page]).per(400).for_render

    #   # unfeasible_investments = Budget::Investment.where("feasibility = ?", "unfeasible")
    #   # @unfeasible_investments_count = unfeasible_investments.count
    #   # @unfesible_investments = unfeasible_investments.page(params[:page]).per(21).for_render
    #   all_investments = Budget::Investment.where("budget_id = ?", @budget.id).order("id DESC")
    #   @all_investments_count = all_investments.count
    #   @all_investments = all_investments.page(params[:page]).per(400).for_render
    #   @all_investment_ids = @investments.pluck(:id)
    end

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
                      :terms_of_service, :related_sdg_list, :price,
                      answers_attributes: [:id, :text, :budget_id, :investment_id, :budget_question_id],
                      image_attributes: image_attributes,
                      documents_attributes: document_attributes,
                      map_location_attributes: map_location_attributes]
        params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
      end

  end
end
