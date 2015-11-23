module OrdersHelper

  def valid_orders
    @valid_orders.reject { |order| order =='relevance' && params[:search].blank? }
  end

end