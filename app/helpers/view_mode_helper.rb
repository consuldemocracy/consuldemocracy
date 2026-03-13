module ViewModeHelper
  def default_view_mode?
    params[:view] != "minimal"
  end
end
