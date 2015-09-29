class Management::BaseController < ActionController::Base
  layout 'admin'

  before_action :verify_manager

  private

    def verify_manager
    end

end
