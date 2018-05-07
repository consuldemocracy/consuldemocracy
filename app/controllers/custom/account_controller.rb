require_dependency Rails.root.join('app', 'controllers', 'account_controller').to_s

class AccountController < ApplicationController

  private

    def account_params
      attributes = if @account.organization?
                     [:phone_number, :email_on_comment, :email_on_comment_reply, :newsletter,
                      organization_attributes: [:name, :responsible_name]]
                   else
                     [:username, :firstname, :lastname, :date_of_birth, :gender, :postal_code, :public_activity, :public_interests, :email_on_comment,
                      :email_on_comment_reply, :email_on_direct_message, :email_digest, :newsletter,
                      :official_position_badge]
                   end
      params.require(:account).permit(*attributes)
    end

end
