class Management::DocumentVerificationsController < Management::BaseController
  before_action :clean_document_number, only: :check
  before_action :set_document, only: :check

  def index
    @document_verification = Verification::Management::Document.new
  end

  def check
    @document_verification = Verification::Management::Document.new(document_verification_params)

    if @document_verification.valid?
      if @document_verification.verified?
        render :verified
      elsif @document_verification.user?
        render :new
      elsif @document_verification.in_census?
        redirect_to new_management_email_verification_path(email_verification: document_verification_params.to_h)
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
    render :verified
  end

  private

    def document_verification_params
      params.require(:document_verification).permit(allowed_params)
    end

    def allowed_params
      [:document_type, :document_number, :date_of_birth, :postal_code]
    end

    def set_document
      session[:document_type] = params[:document_verification][:document_type]
      session[:document_number] = params[:document_verification][:document_number]
      clear_password
    end

    def clean_document_number
      return if params[:document_verification][:document_number].blank?

      params[:document_verification][:document_number] = params[:document_verification][:document_number].gsub(/[^a-z0-9]+/i, "").upcase
    end
end
