module Custom::VerificationHelper
  def document_types
    [[t("verification.residence.new.document_type.spanish_id"), 1],
     [t("verification.residence.new.document_type.passport"), 2],
     [t("verification.residence.new.document_type.residence_card"), 3],
     [t("verification.residence.new.document_type.nie"), 4]]
  end
end
