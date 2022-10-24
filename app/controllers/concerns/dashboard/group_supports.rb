module Dashboard::GroupSupports
  extend ActiveSupport::Concern

  included do
    def grouped_supports(attribute)
      supports.group_by { |v| grouping_key_for(v[attribute].in_time_zone.to_date) }
    end

    def grouping_key_for(date)
      return calculate_week(date) if params[:group_by] == "week"
      return "#{date.year}-#{date.month}" if params[:group_by] == "month"

      date
    end

    def accumulate_supports(grouped_votes)
      grouped_votes.each do |group, votes|
        grouped_votes[group] = votes.reduce(0) { |sum, vote| sum + vote.vote_weight }
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
  end

  private

    def calculate_week(date)
      week = date.cweek
      year = calculate_year_of_week(date)
      "#{week}/#{year}"
    end

    def calculate_year_of_week(date)
      year = date.year
      if first_week_of_year?(date) && date.end_of_week.year != date.year
        year = year + 1
      elsif last_week_of_year?(date) && date.beginning_of_week.year != date.year
        year = year - 1
      end
      year
    end

    def first_week_of_year?(date)
      date.cweek == 1
    end

    def last_week_of_year?(date)
      date.cweek == 52 || date.cweek == 53
    end
end
