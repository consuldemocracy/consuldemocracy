class Admin::OrganizationsController < Admin::BaseController
  has_filters %w[pending all verified rejected], only: :index

  load_and_authorize_resource except: :search

  def index
    @organizations = @organizations.send(@current_filter)
    @organizations = @organizations.includes(:user)
                                   .order("users.created_at", :name, "users.email")
                                   .page(params[:page])
  end

  def search
    @organizations = Organization.includes(:user)
                                 .search(params[:search])
                                 .order("users.created_at", :name, "users.email")
                                 .page(params[:page])
  end

  def verify
    @organization.verify
    redirect_with_query_params_to(action: :index)
  end

  def reject
    @organization.reject
    redirect_with_query_params_to(action: :index)
  end
end
