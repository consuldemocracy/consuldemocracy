module InvestmentFilters
  extend ActiveSupport::Concern

  class_methods do
    def investment_filters
      %w[not_unfeasible feasible unfeasible unselected selected winners]
    end
  end

  def set_default_investment_filter
    if @budget&.balloting? || @budget&.publishing_prices?
      params[:filter] ||= "selected"
    elsif @budget&.finished?
      params[:filter] ||= "winners"
    end
  end
end
