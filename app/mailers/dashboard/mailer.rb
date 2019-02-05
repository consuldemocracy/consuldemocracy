class Dashboard::Mailer < ApplicationMailer
  layout 'mailer'

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end

  def new_actions_notification_on_create(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: I18n.t("mailers.new_actions_notification_on_create.subject")
  end
end
