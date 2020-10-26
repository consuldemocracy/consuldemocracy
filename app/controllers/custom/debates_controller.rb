require_dependency Rails.root.join("app", "controllers", "debates_controller").to_s

class DebatesController

  before_action :redirect, only: :index
  
  def index_customization
    take_only_by_tag_name
    @featured_debates = @debates.featured
  end
  
  def redirect
    if (params[:search].present?) && (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        params[:project] = params[:search]
    end
    
    if (!params[:project].present? || !Tag.category_names.include?(params[:project])) &&
      (!current_user.present? || !(current_user.moderator? || current_user.administrator?)) then
        redirect_to "/"
    end
  end
  
  
  private
    def take_only_by_tag_name
      if params[:project].present?
        @resources = @resources.debates_by_category(params[:project])
      end
    end
    
end
