module ViewModeHelper
  def default_view_mode?
    params[:view] != "minimal"
  end

  def view_mode
    (params[:view] == "minimal") ? "minimal" : "default"
  end

  def secondary_view_mode
    view_mode == "default" ? "minimal" : "default"
  end
end
