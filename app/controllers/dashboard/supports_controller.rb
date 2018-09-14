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

    fill_holes(grouped_votes)
  end

  def grouped_supports
    supports.group_by { |v| grouping_key_for(v.created_at) }
  end

  def grouping_key_for(created_at)
    return "#{created_at.to_date.cweek}/#{created_at.to_date.year}" if params[:group_by] == 'week'
    return "#{created_at.to_date.year}-#{created_at.to_date.month}" if params[:group_by] == 'month'

    created_at.to_date
  end

  def fill_holes(grouped_votes)
    (start_date(proposal.published_at.to_date)..end_date).step(interval).each do |date|
      missing_key = grouping_key_for(date)
      next if grouped_votes.key? missing_key

      previous_key = previous_key_for(date)
      previous_value = if grouped_votes.key? previous_key
                         grouped_votes[previous_key]
                       else
                         0
                       end

      grouped_votes[missing_key] = previous_value
    end

    grouped_votes
  end

  def previous_key_for(date)
    grouping_key_for(date - interval)
  end

  def interval
    return 1.week if params[:group_by] == 'week'
    return 1.month if params[:group_by] == 'month'
    1.day
  end

  def supports
    @supports ||= Vote
                    .where(votable: proposal, created_at: start_date.beginning_of_day..end_date.end_of_day)
                    .order(created_at: :asc)
  end
end
