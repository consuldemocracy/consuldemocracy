class Admin::ConsultantsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @consultants = @consultants.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:consultant)
                 .page(params[:page])
                 .for_render
  end

  def create
    @consultant.user_id = params[:user_id]
    @consultant.save!

    redirect_to admin_consultants_path
  end

  def destroy
    @consultant.destroy!
    redirect_to admin_consultants_path
  end
end
