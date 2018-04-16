class Admin::SignatureSheetsController < Admin::BaseController

  def index
    @signature_sheets = SignatureSheet.all.order(created_at: :desc)
  end

  def new
    @signature_sheet = SignatureSheet.new
  end

  def create
    @signature_sheet = SignatureSheet.new(signature_sheet_params)
    @signature_sheet.author = current_user
    if @signature_sheet.save
      @signature_sheet.delay.verify_signatures
      redirect_to [:admin, @signature_sheet], notice: I18n.t('flash.actions.create.signature_sheet')
    else
      render :new
    end
  end

  def show
    @signature_sheet = SignatureSheet.find(params[:id])
  end

  private

    def signature_sheet_params
      params.require(:signature_sheet).permit(:signable_type, :signable_id, :document_numbers)
    end

end
