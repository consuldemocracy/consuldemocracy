module MeetingProposalsSelectorHelper
  def meeting_proposals_selector(options = {})
    react_component(
      'MeetingProposalsSelector',
      proposals_api_url: api_proposals_url(format: :json),
      proposals: options[:proposals]
    )
  end
end
