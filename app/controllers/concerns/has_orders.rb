module HasOrders
  extend ActiveSupport::Concern

  class_methods do
    def has_orders(valid_orders, *args)
      before_action(*args) do |c|
        valid_orders = valid_orders.call(c) if valid_orders.respond_to?(:call)
        @valid_orders = valid_orders
        @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
      end
    end
  end
end
