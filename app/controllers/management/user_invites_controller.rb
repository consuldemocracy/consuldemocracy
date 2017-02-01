class Management::UserInvitesController < Management::BaseController

  def new
  end

  def create
    @emails = params[:emails].split(",").map(&:strip)
    @emails.each do |email|
      ahoy.track(:user_invite, email: email) rescue nil
      Mailer.user_invite(email).deliver_later
    end
  end

end