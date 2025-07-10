class Admin::SignatureSheetOfficersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @signature_sheet_officers = @signature_sheet_officers.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:signature_sheet_officer)
                 .page(params[:page])
                 .for_render
  end

  def create
    @signature_sheet_officer.user_id = params[:user_id]
    @signature_sheet_officer.save!

    redirect_to admin_signature_sheet_officers_path
  end

  def destroy
    @signature_sheet_officer.destroy!
    redirect_to admin_signature_sheet_officers_path
  end
end
