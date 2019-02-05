class DashboardMailerPreview < ActionMailer::Preview
  def forward
    proposal = Proposal.first
    Dashboard::Mailer.forward(proposal)
  end

  # http://localhost:3000/rails/mailers/dashboard_mailer/new_actions_notification_on_create
  def new_actions_notification_on_create
    proposal = Proposal.first
    Dashboard::Mailer.new_actions_notification_on_create(proposal)
  end
end
