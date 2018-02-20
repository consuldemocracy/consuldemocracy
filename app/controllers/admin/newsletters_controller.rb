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

  def users
    zip = NewsletterZip.new('emails')
    zip.create
    send_file(File.join(zip.path), type: 'application/zip')
  end

  def deliver
    @newsletter = Newsletter.find(params[:id])
    Mailer.newsletter(@newsletter).deliver_later

    @newsletter.update(sent_at: Time.current)

    redirect_to [:admin, @newsletter], notice: t("admin.newsletters.send_success")
  end

  private

    def newsletter_params
      newsletter_params = params.require(:newsletter)
                                .permit(:subject, :segment_recipient, :from, :body)
      newsletter_params.merge(segment_recipient: newsletter_params[:segment_recipient].to_i)
    end
end
