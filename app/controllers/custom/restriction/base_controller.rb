class Restriction::BaseController < ApplicationController
  layout "admin"

  before_action :authenticate_user!
  before_action :verify_signature_sheet_officer

  skip_authorization_check

  private

    def verify_signature_sheet_officer
      raise CanCan::AccessDenied unless current_user&.signature_sheet_officer? || current_user&.administrator?
    end
end
