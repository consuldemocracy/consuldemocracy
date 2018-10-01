module Dashboard::GroupSupports
  extend ActiveSupport::Concern

  included do
    def grouped_supports(attribute)
      supports.group_by { |v| grouping_key_for(v[attribute].to_date) }
    end

    def grouping_key_for(date)
      return "#{date.cweek}/#{date.year}" if params[:group_by] == 'week'
      return "#{date.year}-#{date.month}" if params[:group_by] == 'month'

      date
    end

    def accumulate_supports(grouped_votes)
      grouped_votes.each do |group, votes|
        grouped_votes[group] = votes.inject(0) { |sum, vote| sum + vote.vote_weight }
      end

      accumulated = 0
      grouped_votes.each do |k, v|
        accumulated += v
        grouped_votes[k] = accumulated
      end
    end

    def fill_holes(grouped_votes)
      complete_grouped_votes = {}

      (start_date(proposal.published_at.to_date)..end_date).each do |date|
        key = grouping_key_for(date)
        complete_grouped_votes[key] = if grouped_votes.key? key
                                        grouped_votes[key]
                                      else
                                        []
                                      end
      end

      complete_grouped_votes
    end

    def previous_key_for(date)
      grouping_key_for(date - interval)
    end

    def interval
      return 1.week if params[:group_by] == 'week'
      return 1.month if params[:group_by] == 'month'
      1.day
    end
  end
end
