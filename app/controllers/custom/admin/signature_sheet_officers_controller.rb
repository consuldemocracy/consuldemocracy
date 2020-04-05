class Admin::SignatureSheetOfficersController < Admin::BaseController
  load_and_authorize_resource

  def index
    @signature_sheet_officers = @signature_sheet_officers.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @signature_sheet_officer = SignatureSheetOfficer.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
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
