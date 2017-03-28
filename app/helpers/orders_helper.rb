#Removed in upstream...
module OrdersHelper

  def valid_orders
    return [] unless @valid_orders.present?
    @valid_orders.reject { |order| order =='relevance' && params[:search].blank? }
  end

end