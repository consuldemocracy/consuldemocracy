class Dashboard::Mailer < ApplicationMailer
  layout 'dashboard/mailer'

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end
end
