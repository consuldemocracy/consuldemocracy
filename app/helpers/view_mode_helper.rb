module ViewModeHelper
  def default_view_mode?
    params[:view] != "minimal"
  end

  def view_mode
    if default_view_mode?
      "default"
    else
      "minimal"
    end
  end

  def secondary_view_mode
    if default_view_mode?
      "minimal"
    else
      "default"
    end
  end
end
