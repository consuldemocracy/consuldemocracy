class Admin::OrganizationsController < Admin::BaseController
  before_filter :set_valid_filters
  before_filter :parse_filter

  load_and_authorize_resource

  def index
    @organizations = @organizations.send(@filter)
    @organizations = @organizations.includes(:user).order(:name, 'users.email').page(params[:page])
  end

  def verify
    @organization.verify
    redirect_to action: :index, filter: @filter
  end

  def reject
    @organization.reject
    redirect_to action: :index, filter: @filter
  end

  private
    def set_valid_filters
      @valid_filters = %w{all pending verified rejected}
    end

    def parse_filter
      @filter = params[:filter]
      @filter = 'all' unless @valid_filters.include?(@filter)
    end

end
