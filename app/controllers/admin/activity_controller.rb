class Admin::ActivityController < Admin::BaseController
  has_filters %w{all on_users on_proposals on_debates on_medidas on_comments}

  def show
    @activity = Activity.for_render.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

end
