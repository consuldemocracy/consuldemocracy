class Admin::OrganizationsController < Admin::BaseController
  has_filters %w{pending all verified rejected}, only: :index

  load_and_authorize_resource except: :search

  def index
    @organizations = @organizations.send(@current_filter)
    @organizations = @organizations.includes(:user).order(:name, 'users.email').page(params[:page])
  end

  def search
    @organizations = Organization.search(params[:term]).page(params[:page])
  end

  def verify
    @organization.verify
    redirect_to request.query_parameters.merge(action: :index)
  end

  def reject
    @organization.reject
    redirect_to request.query_parameters.merge(action: :index)
  end

end
