module DebatesHelper
  def available_options_for_order_selector(valid_orders, current_order)
    options_for_select(available_order_filters_array(valid_orders), current_order)
  end

  private

    def available_order_filters_array(orders)
      orders.map { |f| [t("debates.index.order_#{f}"), f] }
    end

end
