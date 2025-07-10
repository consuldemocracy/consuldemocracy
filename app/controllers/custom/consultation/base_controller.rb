class Consultation::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_consultant

  skip_authorization_check

  private

    def verify_consultant
      raise CanCan::AccessDenied unless current_user&.consultant? || current_user&.administrator?
    end
end
