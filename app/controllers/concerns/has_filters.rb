module HasFilters
  extend ActiveSupport::Concern

  class_methods do
    def has_filters(valid_filters, *args)
      before_action(*args) do
        @valid_filters = valid_filters
        @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first
      end
    end
  end
end
