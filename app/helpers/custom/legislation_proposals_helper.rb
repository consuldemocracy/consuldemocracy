module Custom::LegislationProposalsHelper

  def proposal_type_options
    Legislation::Proposal::VALID_TYPES.map { |t| [t("legislation_proposals.label_#{t}"), t] }
  end

end
