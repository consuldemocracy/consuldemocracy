class Dashboard::MailingController < Dashboard::BaseController
  def index
    authorize! :manage_mailing, proposal
  end

  def new
    authorize! :manage_mailing, proposal
  end

  def create
    authorize! :manage_mailing, proposal

    Dashboard::Mailer.forward(proposal).deliver_later
    redirect_to new_proposal_dashboard_mailing_path(proposal),
                flash: { notice: t("dashboard.mailing.create.sent") }
  end
end
