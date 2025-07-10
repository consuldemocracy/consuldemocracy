class Dashboard::SupportsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange
  include Dashboard::GroupSupports

  def index
    authorize! :dashboard, proposal
    render json: accumulated_supports
  end

  private

    def accumulated_supports
      grouped_votes = grouped_supports(:created_at)
      grouped_votes = fill_holes(grouped_votes)
      accumulate_supports(grouped_votes)
    end

    def supports
      @supports ||= Vote
                    .where(votable: proposal,
                           created_at: start_date.beginning_of_day..end_date.end_of_day)
                    .order(created_at: :asc)
    end
end
