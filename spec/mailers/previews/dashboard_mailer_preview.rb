class DashboardMailerPreview < ActionMailer::Preview
  def forward
    proposal = Proposal.first
    Dashboard::Mailer.forward(proposal)
  end
end
