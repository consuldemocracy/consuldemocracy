class Users::SessionsController < Devise::SessionsController

  def after_sign_in_path_for(resource)
    if stored_path_allows_welcome_screen? && resource.show_welcome_screen?
      welcome_path
    else
      super
    end
  end

  private

    def stored_path_allows_welcome_screen?
      stored_path = session[stored_location_key_for(resource)]
      stored_path.nil? || stored_path[0..5] != "/email"
    end

end
