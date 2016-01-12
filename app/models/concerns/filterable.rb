module Filterable
  extend ActiveSupport::Concern

  class_methods do

    def filter(params)
      resources = self.all
      filters = parse_filters(params)

      if filters[:params_author]
        author = User.where(username: filters[:params_author])
        resources = author.count > 0 ? self.where(author_id: author.first.id) : self.none
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
          resources = self.where('created_at <= ?', filters[:params_date_max]) if filters[:params_date_max]
          min_date_time = filters[:params_date_min]
        end
        resources = self.where('created_at >= ?', min_date_time) if min_date_time
      end
      if filters[:params_author_type]
        authors = User.where(official_level: filters[:params_author_type].to_i)
        resources = self.where('author_id IN (?)', authors.map(&:id))
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