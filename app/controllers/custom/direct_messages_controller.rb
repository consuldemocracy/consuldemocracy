require_dependency Rails.root.join("app", "controllers", "direct_messages_controller").to_s

class DirectMessagesController < ApplicationController
  def create
    @sender = current_user
    @receiver = User.find(params[:user_id])

    @direct_message = DirectMessage.new(parsed_params)
    if @direct_message.save
      Mailer.direct_message_for_receiver(@direct_message).deliver_later if @receiver.email.present?
      Mailer.direct_message_for_sender(@direct_message).deliver_later if @sender.email.present?
      redirect_to [@receiver, @direct_message], notice: I18n.t("flash.actions.create.direct_message")
    else
      render :new
    end
  end
end
