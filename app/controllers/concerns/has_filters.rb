module HasFilters
  extend ActiveSupport::Concern

  attr_reader :valid_filters, :current_filter

  included do
    helper_method :valid_filters, :current_filter
  end

  class_methods do
    def has_filters(valid_filters, *)
      before_action(*) do
        @valid_filters = valid_filters.respond_to?(:call) ? valid_filters.call(self) : valid_filters
        @current_filter = @valid_filters.include?(params[:filter]) ? params[:filter] : @valid_filters.first
      end
    end
  end
end
