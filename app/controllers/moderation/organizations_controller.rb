class Moderation::OrganizationsController < Moderation::BaseController

  before_filter :load_organizations, only: :index
  load_and_authorize_resource class: 'User'

  def index
  end

  def verify_organization
    @organization.update(organization_verified_at: Time.now)
    redirect_to action: :index
  end

  def reject_organization
    @organization.update(organization_rejected_at: Time.now)
    redirect_to action: :index
  end

  private

    def load_organizations
      @organizations = User.organizations.order(:organization_name, :email)
    end

end
