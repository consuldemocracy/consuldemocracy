module HasOrders
  extend ActiveSupport::Concern
  attr_reader :valid_orders, :current_order

  included do
    helper_method :valid_orders, :current_order
  end

  class_methods do
    def has_orders(valid_orders, *args)
      before_action(*args) do |c|
        @valid_orders = valid_orders.respond_to?(:call) ? valid_orders.call(c) : valid_orders.dup
        @valid_orders.delete("relevance") if params[:search].blank?
        @current_order = @valid_orders.include?(params[:order]) ? params[:order] : @valid_orders.first
      end
    end
  end
end
