class Dashboard::Mailer < ApplicationMailer
  layout 'mailer'

  def forward(proposal)
    @proposal = proposal
    mail to: proposal.author.email, subject: proposal.title
  end
end
