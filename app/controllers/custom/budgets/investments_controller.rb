require_dependency Rails.root.join("app", "controllers", "budgets", "investments_controller").to_s

module Budgets
  class InvestmentsController < ApplicationController
    PER_PAGE = 12
    SHOW_TOP_INVESTMENTS = false
    NUMBER_OF_TOP_PROJECTS = 3
    MISSING_A_LITTLE_TO_TOP = 10

    before_action :load_categories, only: [:index, :new, :create, :edit, :update]
    # before_action :load_budgets,  only: [:index, :new, :create, :edit, :update]

    # has_orders ->(c) { c.investments_orders }, only: :index

    # def load_budgets
    #   @budgets = Budget.where("id > -1");
    # end

    
    def load_categories
      @categories = Tag.category.order(:name)
    end

    def show
      @commentable = @investment
      @comment_tree = CommentTree.new(@commentable, params[:page], @current_order)
      set_comment_flags(@comment_tree.comments)
      @investment_ids = [@investment.id]
      @remote_translations = detect_remote_translations([@investment], @comment_tree.comments)

      @show_top_investments = SHOW_TOP_INVESTMENTS

      if (SHOW_TOP_INVESTMENTS && @budget.phase == "balloting")
        @top_investments = @budget.investments.where("selected = ? AND feasibility = ?", true, "feasible").order(ballot_lines_count: :desc).limit(NUMBER_OF_TOP_PROJECTS)
        
        unless (@top_investments.empty?)
          @top_investments_ids = @top_investments.ids

          if @investment.ballot_lines_count >= @top_investments.last.ballot_lines_count
            @is_top_investment = true
          else
            @is_top_investment = false

            if @top_investments.last.ballot_lines_count - @investment.ballot_lines_count <= MISSING_A_LITTLE_TO_TOP
              @missing_a_little = true
            else
              @missing_a_little = false
            end
          end
        end
      end
    end

    def index

      # FILTERING
      # 'filtered_investments' is the variable representing final result

      # query parameters
      param_heading = params[:heading_id] # obmocje
      param_tag_name = params[:tag_name] # mestna cetrt
      param_chosen = params[:chosen] # izbrani oz. selected, "false" or else
      param_unfeasible = params[:unfeasible] # izglasovani oz. winners
      param_status = params[:status_id] # status

      # filter by heading in all phases
      if param_heading
        filtered_investments = @budget.investments.where(heading_id: param_heading)
      else
        filtered_investments = @budget.investments.all
      end

      # filter by tag in all phases
      if param_tag_name
        filtered_investments = filtered_investments.tagged_with(param_tag_name)
      end

      if (@budget.phase == "publishing_prices") || (@budget.phase == "balloting") || (@budget.phase == "reviewing_ballots")
        # filter by selected
        if param_chosen == "false"
          filtered_investments = filtered_investments.where("selected = ? OR feasibility = ?", false, "unfeasible")
        else
          filtered_investments = filtered_investments.where("selected = ? AND feasibility = ?", true, "feasible")
        end

      elsif @budget.phase == "finished"
        # filter by status
        if param_status
          investment_ids = []
          Budget::Investment.all.order(:id).each do |investment|
            if investment.milestones.count > 0
              if investment.milestones.order_by_publication_date.last.status_id == params[:status_id].to_i
                investment_ids.push(investment.id)
              end
            end
          end
          filtered_investments = filtered_investments.where(id: investment_ids)
        else
          filtered_investments = filtered_investments
        end

        # filter by winner
        winner_ids = []
        @budget.investments.winners.order(:id).each do |investment|
          winner_ids.push(investment.id)
        end
        if param_unfeasible
          filtered_investments = filtered_investments.where.not(id: winner_ids)
        else
          filtered_investments = filtered_investments.where(id: winner_ids)
        end
      end

      # pagination
      @filtered_investments_count = filtered_investments.count
      @investments = filtered_investments.page(params[:page]).per(PER_PAGE).for_render

      # filters data
      @statuses = Milestone::Status.all

      # map
      @investment_ids = @investments.ids
      @investments_map_coordinates = MapLocation.where(investment: filtered_investments).map(&:json_data)

      # ?
      @tag_cloud = tag_cloud
      @remote_translations = detect_remote_translations(@investments)

      # TODO: remove this commented out section when you're sure you don't need it anywhere
      #@denied_investments = Budget::Investment.where(selected: false).page(params[:page]).per(21).for_render
      # if @budget.phase == "finished"
      #   if @heading
      #     denied_investments = Budget::Investment.where("winner = false AND budget_id = ?",
      #       @budget.id).where("heading_id = ?", @heading.id)
      #   else
      #     denied_investments = Budget::Investment.where("winner = false AND budget_id = ?", @budget.id)
      #   end
      # else
      #   if @heading
      #     denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
      #     .where("budget_id = ?", @budget.id).where("heading_id = ?", @heading.id)
      #   else
      #     denied_investments = Budget::Investment.where("selected = false OR feasibility = ?", "unfeasible")
      #     .where("budget_id = ?", @budget.id)
      #   end
      # end
      # @denied_investments_count = denied_investments.count
      # @denied_investments = denied_investments.page(params[:page]).per(400).for_render

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
