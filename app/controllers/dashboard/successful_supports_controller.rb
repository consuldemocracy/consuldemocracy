class Dashboard::SuccessfulSupportsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange
  include Dashboard::GroupSupports

  def index
    authorize! :dashboard, proposal
    render json: accumulated_grouped_supports
  end

  private

    def accumulated_grouped_supports
      grouped_votes = grouped_supports(:voted_at)
      grouped_votes = fill_holes(grouped_votes)
      accumulate_supports(grouped_votes)
    end

    def supports
      return [] if successful_proposal.nil?

      Vote
        .select("created_at + interval '#{days_diff} day' voted_at, *")
        .where(votable: successful_proposal)
        .where("created_at + interval '#{days_diff} day' between ? and ?",
               start_date.beginning_of_day, end_date.end_of_day)
        .order(created_at: :asc)
    end

    def successful_proposal
      @successful_proposal ||= Proposal.find_by(id: Setting["proposals.successful_proposal_id"])
    end

    def days_diff
      return 0 if successful_proposal.nil?
      return 0 if proposal.published_at.nil?

      (proposal.published_at.to_date - successful_proposal.published_at.to_date).to_i
    end
end
