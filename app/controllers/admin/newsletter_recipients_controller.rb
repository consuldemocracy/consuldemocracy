class Admin::NewsletterRecipientsController < Admin::BaseController
  load_and_authorize_resource

  has_filters %w[active inactive], only: :index

  def index
    @newsletter_recipients = @current_filter ? filtered_data : NewsletterRecipient.all
    @newsletter_recipients = @newsletter_recipients.by_email(params[:search]) if params[:search]
    @newsletter_recipients = @newsletter_recipients.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

    def filtered_data
      return @newsletter_recipients.active if @current_filter&.downcase == "active"

      @newsletter_recipients.inactive
    end
end
