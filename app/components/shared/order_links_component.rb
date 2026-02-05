class Shared::OrderLinksComponent < ApplicationComponent
  attr_reader :i18n_namespace, :anchor
  delegate :current_path_with_query_params, :current_order, :valid_orders, to: :helpers

  def initialize(i18n_namespace, anchor: nil)
    @i18n_namespace = i18n_namespace
    @anchor = anchor
  end

  private

    def html_class(order)
      "is-active" if order == current_order
    end

    def tag_name(order)
      if order == current_order
        :h2
      else
        :span
      end
    end

    def link_path(order)
      current_path_with_query_params(order: order, page: 1, anchor: anchor)
    end

    def link_text(order)
      t("#{i18n_namespace}.orders.#{order}")
    end
end
