class Tracking::BudgetInvestmentsController < Tracking::BaseController
  include FeatureFlags
  include CommentableActions

  feature_flag :budgets

  before_action :restrict_access_to_assigned_items, only: [:show, :edit]
  before_action :load_budget
  before_action :load_investment, only: [:show, :edit]

  has_orders %w{oldest}, only: [:show, :edit]

  load_and_authorize_resource :investment, class: "Budget::Investment"

  def index
    @heading_filters = heading_filters
    @investments = if current_user.tracker? && @budget.present?
                     current_user.tracker.investments_by_heading(heading_params, @budget)
                       .page(params[:page])
                   else
                     Budget::Investment.none.page(params[:page])
                   end
  end

  def show
  end

  def edit
  end

  private

    def resource_model
      Budget::Investment
    end

    def resource_name
      resource_model.parameterize(separator: "_")
    end

    def load_budget
      @budget = Budget.find(params[:budget_id])
    end

    def load_investment
      @investment = @budget.investments.find params[:id]
    end

    def heading_filters
      investments = @budget.investments.by_tracker(current_user.tracker.try(:id))
                                       .distinct
      investment_headings = Budget::Heading.where(id: investments.pluck(:heading_id).uniq)
                                           .order(name: :asc)
      all_headings_filter = [
                              {
                                name: t("valuation.budget_investments.index.headings_filter_all"),
                                id: nil,
                                count: investments.size
                              }
                            ]

      filters = investment_headings.inject(all_headings_filter) do |filters, heading|
        filters << {
          name: heading.name,
          id: heading.id,
          count: investments.select{|i| i.heading_id == heading.id}.size
        }
      end
      filters.uniq
    end

    def restrict_access_to_assigned_items
      return if current_user.administrator? ||
                Budget::TrackerAssignment.exists?(investment_id: params[:id],
                                                   tracker_id: current_user.tracker.id)
      raise ActionController::RoutingError.new("Not Found")
    end

    def heading_params
      params.permit(:heading_id)
    end

end
