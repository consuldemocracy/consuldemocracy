module Dashboard::ExpectsDateRange
  extend ActiveSupport::Concern

  include Dashboard::HasProposal

  def start_date(fallback_date = proposal.created_at.to_date)
    return Date.parse(params[:start_date]) unless params[:start_date].blank?

    fallback_date
  end

  def end_date
    return Date.parse(params[:end_date]) unless params[:end_date].blank?

    Date.current
  end
end
