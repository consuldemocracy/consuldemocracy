class Users::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    if !verifying_via_email? && resource.show_welcome_screen?
      welcome_path
    else
      super
    end
  end

  private

    def verifying_via_email?
      stored_path = session[stored_location_key_for(resource)] || ""
      stored_path[0..5] == "/email"
    end

end
