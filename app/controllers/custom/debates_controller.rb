require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController

  before_action :redirect, only: :index

  def redirect
    if (!params[:search].present? || !Tag.category_names.include?(params[:search])) &&
      (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        redirect_to "/"
    end
  end
end
