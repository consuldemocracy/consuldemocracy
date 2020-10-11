require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController

  before_action :redirect, only: :index

  def redirect
    if !params[:search].present? &&
      (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        redirect_to "/"
    end
  end
end
