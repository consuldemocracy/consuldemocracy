class Admin::AnimatorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @animators = @animators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:animator)
                 .page(params[:page])
                 .for_render
  end

  def create
    @animator.user_id = params[:user_id]
    @animator.save

    redirect_to admin_animators_path
  end

  def destroy
    @animator.destroy
    redirect_to admin_animators_path
  end
end
