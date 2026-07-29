class Admin::Sensemaker::ResultComponent < ViewComponent::Base
  def initialize(result_group:, selected_query_type:)
    @result_group = result_group
    @selected_query_type = selected_query_type
  end

  def render?
    @result_group[:collection].present? && @result_group[:collection].any?
  end
end
