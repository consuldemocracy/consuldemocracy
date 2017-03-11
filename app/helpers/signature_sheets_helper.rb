module SignatureSheetsHelper

  def signable_options
    [[t("activerecord.models.proposal", count: 1), Proposal],
     [t("activerecord.models.spending_proposal", count: 1), SpendingProposal]]
  end

end