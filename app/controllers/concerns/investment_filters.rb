module InvestmentFilters
  extend ActiveSupport::Concern

  class_methods do
    def investment_filters
      ->(controller) { controller.investment_filters }
    end
  end

  def set_default_investment_filter
    if @budget&.finished?
      params[:filter] ||= "winners"
    elsif @budget&.publishing_prices_or_later?
      params[:filter] ||= "selected"
    end
  end

  def investment_filters
    [
      "not_unfeasible",
      "unfeasible",
      ("unselected" if @budget.publishing_prices_or_later?),
      ("selected" if @budget.publishing_prices_or_later?),
      ("winners" if @budget.finished?)
    ].compact
  end
end
