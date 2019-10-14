module SignatureSheetsHelper

  def signable_options
    [[t("activerecord.models.proposal", count: 1), Proposal],
     [t("activerecord.models.budget/investment", count: 1), Budget::Investment]]
  end

end