class Officing::BaseController < ApplicationController
  layout 'admin'
  helper_method :current_booth

  before_action :authenticate_user!
  before_action :verify_officer

  skip_authorization_check

  private

    def verify_officer
      raise CanCan::AccessDenied unless current_user.try(:poll_officer?) || current_user.try(:administrator?)
    end

    def load_officer_assignment
      @officer_assignments ||= current_user.poll_officer.
                               officer_assignments.
                               voting_days.
                               where(date: Time.current.to_date)
    end

    def verify_officer_assignment
      if @officer_assignments.blank?
        redirect_to officing_root_path, notice: t("officing.residence.flash.not_allowed")
      end
    end

    def verify_booth
      if current_booth.blank?
        redirect_to new_officing_booth_path
      end
    end

    def current_booth
      Poll::Booth.where(id: session[:booth_id]).first
    end

    def letter?
      false
    end

end
