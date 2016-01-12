module Filterable
  extend ActiveSupport::Concern

  included do
    scope :by_author,         -> (author)         { where(author: author) }
    scope :by_official_level, -> (official_level) { where(users: { official_level: official_level }).joins(:author) }
    scope :by_date_range,     -> (start, finish)  { where(created_at: start.beginning_of_day..finish.end_of_day) }
  end

  class_methods do
    def filter(params)
      resources = self.all
      filters = parse_filters(params)

      if filters[:params_author]
        author = User.where(username: filters[:params_author]).first
        resources = author.present? ? self.by_author(author) : self.none
      end

      if filters[:params_date]
        case filters[:params_date]
        when '1'
          min_date_time = DateTime.now - 24.hour
        when '2'
          min_date_time = DateTime.now - 7.day
        when '3'
          min_date_time = DateTime.now - 30.day
        when '4'
          min_date_time = DateTime.now - 365.day
        when '5'
          min_date_time = filters[:params_date_min].to_time
        end

        max_date_time = filters[:params_date_max].present? ? filters[:params_date_max].to_time : DateTime.now
        if min_date_time && max_date_time
          resources = self.by_date_range(min_date_time, max_date_time)
        end
      end

      if filters[:params_author_type]
        resources = self.by_official_level(filters[:params_author_type].to_i)
      end
      resources
    end

    def parse_filters(params)
      search = params
      filters = {}
      if search
        filters[:params_author] = search[:author] if search[:author].present?
        filters[:params_author_type] = search[:author_type] if search[:author_type].present?

        filters[:params_date] = search[:date] if search[:date].present?
        filters[:params_date_min] = search[:date_min] if (filters[:params_date] == '5') && search[:date_min].present?
        filters[:params_date_max] = search[:date_max] if (filters[:params_date]== '5') && search[:date_max].present?

        filters[:advanced_search_present] = true if params[:commit] || filters[:params_author] || filters[:params_author_type] || filters[:params_date]
      end
      filters
    end
  end

end