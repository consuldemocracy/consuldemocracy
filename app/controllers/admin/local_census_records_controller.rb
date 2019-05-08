class Admin::LocalCensusRecordsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @local_census_records = @local_census_records.search(params[:search])
    @local_census_records = @local_census_records.page(params[:page])
  end
end
