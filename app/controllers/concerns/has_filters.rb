module HasFilters
  extend ActiveSupport::Concern

  class_methods do
    def has_filters(valid_filters, *args)
      before_action(*args) do
        @valid_filters = valid_filters
        @current_filter = params[:filter]
        @current_filter = @valid_filters.first unless @valid_filters.include?(@current_filter)
      end
    end
  end
end
