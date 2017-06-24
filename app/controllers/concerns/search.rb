module Search
  extend ActiveSupport::Concern

  included do
    before_action :parse_search_terms, only: [:index, :suggest]
    before_action :parse_advanced_search_terms, only: :index
    before_action :set_search_order, only: :index
  end

  def parse_search_terms
    @search_terms = params[:search] if params[:search].present?
  end

  def parse_advanced_search_terms
    @advanced_search_terms = params[:advanced_search] if params[:advanced_search].present?
    parse_search_date
  end

  def parse_search_date
    return unless search_by_date?
    params[:advanced_search][:date_range] = search_date_range
  end

  def search_by_date?
    params[:advanced_search] && params[:advanced_search][:date_min].present?
  end

  def search_start_date
    case params[:advanced_search][:date_min]
    when '1'
      24.hours.ago
    when '2'
      1.week.ago
    when '3'
      1.month.ago
    when '4'
      1.year.ago
    else
      Date.parse(params[:advanced_search][:date_min]) rescue 100.years.ago
    end
  end

  def search_finish_date
    (params[:advanced_search][:date_max].to_date rescue Date.current) || Date.current
  end

  def search_date_range
    [100.years.ago, search_start_date].max.beginning_of_day..[search_finish_date, Date.current].min.end_of_day
  end

  def set_search_order
    if params[:search].present? && params[:order].blank?
      params[:order] = 'relevance'
    end
  end

end
