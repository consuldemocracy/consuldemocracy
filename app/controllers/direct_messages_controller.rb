class DirectMessagesController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource :user, instance_name: :receiver
  before_action :check_slug
  load_resource through: :receiver, through_association: :direct_messages_received
  authorize_resource except: :new

  def new
    authorize! :new, @direct_message, message: t("users.direct_messages.new.verified_only",
                                                 verify_account: helpers.link_to_verify_account)
  end

  def create
    @direct_message.sender = current_user

    if @direct_message.save
      Mailer.direct_message_for_receiver(@direct_message).deliver_later
      Mailer.direct_message_for_sender(@direct_message).deliver_later

      redirect_to user_direct_message_path(@receiver, @direct_message),
                  notice: I18n.t("flash.actions.create.direct_message")
    else
      render :new
    end
  end

  def show
  end

  private

    def check_slug
      slug = params[:user_id].split("-", 2)[1]

      raise ActiveRecord::RecordNotFound unless @receiver.slug == slug.to_s
    end

    def direct_message_params
      params.require(:direct_message).permit(allowed_params)
    end

    def allowed_params
      [:title, :body]
    end
end
