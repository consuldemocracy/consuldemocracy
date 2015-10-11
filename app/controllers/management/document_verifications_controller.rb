class Management::DocumentVerificationsController < Management::BaseController

  def index
    @document_verification = Verification::Management::Document.new()
  end

  def check
    @document_verification = Verification::Management::Document.new(document_verification_params)

    if @document_verification.valid?
      if @document_verification.verified?
        set_managed_user(@document_verification.user)
        render :verified
      elsif @document_verification.user?
        render :new
      elsif @document_verification.in_census?
        redirect_to new_management_email_verification_path(email_verification: document_verification_params)
      else
        render :invalid_document
      end
    else
      render :index
    end
  end

  def create
    @document_verification = Verification::Management::Document.new(document_verification_params)
    @document_verification.verify
    set_managed_user(@document_verification.user)
    render :verified
  end

  private

  def document_verification_params
    params.require(:document_verification).permit(:document_type, :document_number)
  end

end