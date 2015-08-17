class Admin::OrganizationsController < Admin::BaseController

  load_and_authorize_resource

  def index
    @organizations = @organizations.includes(:user).order(:name, 'users.email')
  end

  def verify
    @organization.verify
    redirect_to action: :index
  end

  def reject
    @organization.reject
    redirect_to action: :index
  end

end
