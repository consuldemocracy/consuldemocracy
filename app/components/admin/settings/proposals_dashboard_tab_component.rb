class Admin::Settings::ProposalsDashboardTabComponent < ApplicationComponent
  def settings
    %w[
      proposals.successful_proposal_id
      proposals.poll_short_title
      proposals.poll_description
      proposals.poll_link
      proposals.email_short_title
      proposals.email_description
      proposals.poster_short_title
      proposals.poster_description
    ]
  end
end
