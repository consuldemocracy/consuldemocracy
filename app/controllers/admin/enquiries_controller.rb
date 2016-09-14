class Admin::EnquiriesController < Admin::BaseController
  load_and_authorize_resource

  def index
    @enquiries = @enquiries.page(params[:page])
  end

  def new
  end

  def create
    if @enquiry.save
      redirect_to @enquiry
    else
      render :new
    end
  end

  def edit

  end

  def update
    if @enquiry.save
      redirect_to @enquiry
    else
      render :edit
    end
  end

  def destroy
    notice = t("flash.actions.destroy.error") unless @enquiry.delete
    redirect_to admin_enquiries_path, notice: notice
  end

end
