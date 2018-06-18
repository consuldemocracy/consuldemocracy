class Moderation::Budgets::InvestmentsController < Moderation::BaseController
  include FeatureFlags
  include ModerateActions

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders  %w{flags created_at}, only: :index

  feature_flag :budgets

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource class: 'Budget::Investment'

  private

    def resource_name
      'budget_investment'
    end

    def resource_model
      Budget::Investment
    end

end
