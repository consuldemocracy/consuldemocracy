class Moderation::InvestmentsController < Moderation::BaseController
  include ModerateActions

  before_action :find_in

  has_filters %w{pending_flag_review all with_ignored_flag}, only: :index
  has_orders %w{created_at}, only: :index

  before_action :load_resources, only: [:index, :moderate]

  load_and_authorize_resource class: "Budget::Investment"

  private

    def resource_model
      Budget::Investment
    end

    def find_in
      @current_filter = 'all'
      @current_order = 'random'
    end

    def set_resources_instance
      instance_variable_set("@budget_investmens", @resources)
    end

end
