class Admin::OrganizationsController < Admin::BaseController
  before_filter :set_valid_filters, only: :index
  before_filter :parse_filter, only: :index

  load_and_authorize_resource

  def index
    @organizations = @organizations.send(@filter)
    @organizations = @organizations.includes(:user).order(:name, 'users.email').page(params[:page])
  end

  def verify
    @organization.verify
    redirect_to request.query_parameters.merge(action: :index)
  end

  def reject
    @organization.reject
    redirect_to request.query_parameters.merge(action: :index)
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
