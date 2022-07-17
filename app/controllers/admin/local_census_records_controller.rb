class Admin::LocalCensusRecordsController < Admin::BaseController
  load_and_authorize_resource class: "LocalCensusRecord"

  def index
    @local_census_records = @local_census_records.search(params[:search])
    @local_census_records = @local_census_records.page(params[:page])
  end

  def create
    @local_census_record = LocalCensusRecord.new(local_census_record_params)
    if @local_census_record.save
      redirect_to admin_local_census_records_path,
        notice: t("admin.local_census_records.create.notice")
    else
      render :new
    end
  end

  def update
    if @local_census_record.update(local_census_record_params)
      redirect_to admin_local_census_records_path,
        notice: t("admin.local_census_records.update.notice")
    else
      render :edit
    end
  end

  def destroy
    @local_census_record.destroy!
    redirect_to admin_local_census_records_path,
      notice: t("admin.local_census_records.destroy.notice")
  end

  private

    def local_census_record_params
      params.require(:local_census_record).permit(allowed_params)
    end

    def allowed_params
      [:document_type, :document_number, :date_of_birth, :postal_code]
    end
end
