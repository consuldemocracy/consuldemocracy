class Shared::FilterSelectorComponent < ApplicationComponent
  delegate :valid_filters, :current_filter, to: :helpers
  attr_reader :i18n_namespace

  def initialize(i18n_namespace:)
    @i18n_namespace = i18n_namespace
  end

  private

    def query_parameters_tags
      safe_join(request.query_parameters.reject do |name, _|
        ["page", "filter"].include?(name)
      end.map do |name, value|
        hidden_field_tag name, value, id: "filter_selector_#{name}"
      end)
    end

    def filter_options
      valid_filters.map { |filter| [t("#{i18n_namespace}.filters.#{filter}"), filter] }
    end
end
