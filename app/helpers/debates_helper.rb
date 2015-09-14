module DebatesHelper
  def return_query_params
    hash = { order: session.delete(:return_order) }
    hash.merge(page_hash) if session[:return_page]
  end

  def page_hash
    { page: session.delete(:return_page) }
  end
end
