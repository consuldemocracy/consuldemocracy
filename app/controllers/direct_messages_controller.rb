class DirectMessagesController < ApplicationController
  load_and_authorize_resource :user, instance_name: :receiver
  load_and_authorize_resource through: :receiver, through_association: :direct_messages_received

  def new
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

    def direct_message_params
      params.require(:direct_message).permit(allowed_params)
    end

    def allowed_params
      [:title, :body]
    end
end
