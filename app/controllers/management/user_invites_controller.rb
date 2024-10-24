class Management::UserInvitesController < Management::BaseController
  def new
  end

  def create
    @emails = params[:emails].split(",").map(&:strip)
    @emails.each do |email|
      Mailer.user_invite(email).deliver_later
    end
  end
end
