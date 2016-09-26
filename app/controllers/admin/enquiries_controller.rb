class Admin::EnquiriesController < Admin::BaseController
  load_and_authorize_resource
  before_action :load_geozones, only: [:new, :create, :edit, :update]

  def index
    @enquiries = @enquiries.page(params[:page])
  end

  def new
    @enquiry.open_at = Date.today.to_datetime
    @enquiry.closed_at = 1.month.from_now
    @enquiry.valid_answers = I18n.t('enquiries.default_valid_answers')
    proposal = Proposal.find(params[:proposal_id]) if params[:proposal_id].present?
    @enquiry.copy_attributes_from_proposal(proposal)
  end

  def create
    @enquiry.author = @enquiry.proposal.try(:author) || current_user

    if @enquiry.save
      redirect_to enquiry_path(@enquiry)
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @enquiry.update(enquiry_params)
      redirect_to enquiry_path(@enquiry), notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def destroy
    notice = t("flash.actions.destroy.error") unless @enquiry.delete
    redirect_to admin_enquiries_path, notice: notice
  end

  private

    def load_geozones
      @geozones = Geozone.all.order(:name)
    end

    def enquiry_params
      params.require(:enquiry).permit(:title, :question, :summary, :description, :external_url, :open_at, :closed_at, :proposal_id, :valid_answers, :geozone_ids => [])
    end

end
