class Admin::LocalCensusRecords::ImportsController < Admin::LocalCensusRecords::BaseController
  load_and_authorize_resource class: "LocalCensusRecords::Import"

  def create
    @import = LocalCensusRecords::Import.new(local_census_records_import_params)
    if @import.save
      flash.now[:notice] = t("admin.local_census_records.imports.create.notice")
      render :show
    else
      render :new
    end
  end

  private

    def local_census_records_import_params
      return {} unless params[:local_census_records_import].present?

      params.require(:local_census_records_import).permit(allowed_params)
    end

    def allowed_params
      [:file]
    end
end
