class Admin::NewslettersController < Admin::BaseController

  def index
    @newsletters = Newsletter.all
  end

  def show
    @newsletter = Newsletter.find(params[:id])
  end

  def new
    @newsletter = Newsletter.new
  end

  def create
    @newsletter = Newsletter.new(newsletter_params)

    if @newsletter.save
      notice = t("admin.newsletters.create_success")
      redirect_to [:admin, @newsletter], notice: notice
    else
      render :new
    end
  end

  def edit
    @newsletter = Newsletter.find(params[:id])
  end

  def update
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.update(newsletter_params)
      redirect_to [:admin, @newsletter], notice: t("admin.newsletters.update_success")
    else
      render :edit
    end
  end

  def destroy
    @newsletter = Newsletter.find(params[:id])
    @newsletter.destroy

    redirect_to admin_newsletters_path, notice: t("admin.newsletters.delete_success")
  end

  def deliver
    @newsletter = Newsletter.find(params[:id])

    if @newsletter.valid?
      @newsletter.delay.deliver
      @newsletter.update(sent_at: Time.current)
      flash[:notice] = t("admin.newsletters.send_success")
    else
      flash[:error] = t("admin.segment_recipient.invalid_recipients_segment")
    end

    redirect_to [:admin, @newsletter]
  end

  private

    def newsletter_params
      params.require(:newsletter).permit(:subject, :segment_recipient, :from, :body)
    end
end
