module Analytics
  extend ActiveSupport::Concern

  def log_event(category, action, name=nil, custom_value=nil, dimension=nil, dimension_value=nil)
    category        = I18n.t("tracking.events.category.#{category}")
    action          = I18n.t("tracking.events.action.#{action}")

    session[:event] = {category: category, action: action, name: name.to_s, custom_value: custom_value.to_s, dimension: dimension.to_s, dimension_value: dimension_value.to_s}
  end

end