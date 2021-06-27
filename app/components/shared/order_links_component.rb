class Shared::OrderLinksComponent < ApplicationComponent
  attr_reader :i18n_namespace
  delegate :current_path_with_query_params, :current_order, :valid_orders, to: :helpers

  def initialize(i18n_namespace)
    @i18n_namespace = i18n_namespace
  end
end
