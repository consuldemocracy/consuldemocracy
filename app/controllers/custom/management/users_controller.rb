require_dependency Rails.root.join('app', 'controllers', 'management', 'users_controller').to_s

class Management::UsersController < Management::BaseController

  private

    def user_params
      params.require(:user).permit(:document_type, :document_number, :username, :email, :date_of_birth,
        :lastname, :firstname, :postal_code)
    end

end
