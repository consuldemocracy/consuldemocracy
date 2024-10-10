module Dashboard::ExpectsDateRange
  extend ActiveSupport::Concern

  include Dashboard::HasProposal

  def start_date(fallback_date = proposal.created_at.to_date)
    return Date.parse(params[:start_date]) if params[:start_date].present?

    fallback_date
  end

  def end_date
    return Date.parse(params[:end_date]) if params[:end_date].present?

    Date.current
  end
end
