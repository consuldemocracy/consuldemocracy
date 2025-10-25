class NewsletterRecipientsController < ApplicationController
  skip_authorization_check
  before_action :find_record, only: %i[edit destroy]

  def new
    @newsletter_recipient = NewsletterRecipient.new
  end

  def create
    @newsletter_recipient = NewsletterRecipient.new(permited_params)
    if @newsletter_recipient.save
      Mailer.newsletter_recipients_invitation(@newsletter_recipient).deliver_later
      redirect_to root_path, notice: t("welcome.feed.newsletters_receptions.subscribed")
    else
      redirect_to root_path, alert: @newsletter_recipient.errors.messages.values.join()
    end
  end

  def edit
    unless @record
      return redirect_to root_path, error: t("welcome.feed.newsletters_receptions.confirmation_failed")
    end

    @record.update!(confirmed_at: Time.zone.now) unless @record.confirmed_at
    redirect_to root_path, notice: t("welcome.feed.newsletters_receptions.confirmation_success")
  end

  def destroy
    unless @record
      return redirect_to root_path, error: t("welcome.feed.newsletters_receptions.stop_subscription_failed")
    end

    @record.destroy!
    redirect_to root_path, notice: t("welcome.feed.newsletters_receptions.stop_subscription_success")
  end

  private

    def find_record
      @record = NewsletterRecipient.find_by(token: params[:token])
    end

    def permited_params
      params.require(:newsletter_recipient).permit(:email)
    end
end
