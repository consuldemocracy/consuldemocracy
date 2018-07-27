class Dashboard::SupportsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange

  def index
    authorize! :dashboard, proposal
    render json: accumulated_supports
  end

  private

  def accumulated_supports
    grouped_votes = grouped_supports
    grouped_votes.each do |group, votes|
      grouped_votes[group] = votes.inject(0) { |sum, vote| sum + vote.vote_weight }
    end

    accumulated = 0
    grouped_votes.each do |k, v|
      accumulated += v
      grouped_votes[k] = accumulated
    end

    grouped_votes
  end

  def grouped_supports
    if params[:group_by] == 'week'
      return supports.group_by { |v| "#{v.created_at.to_date.cweek}/#{v.created_at.to_date.year}" }
    end

    if params[:group_by] == 'month'
      return supports.group_by { |v| "#{v.created_at.to_date.year}-#{v.created_at.to_date.month}" }
    end

    supports.group_by { |v| v.created_at.to_date }
  end

  def supports
    @supports ||= Vote
                    .where(votable: proposal, created_at: start_date.beginning_of_day..end_date.end_of_day)
                    .order(created_at: :asc)
  end
end
