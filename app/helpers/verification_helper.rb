module VerificationHelper
  def document_types
    [[t("verification.residence.new.document_type.spanish_id"), 1],
     [t("verification.residence.new.document_type.passport"), 2],
     [t("verification.residence.new.document_type.residence_card"), 3]]
  end

  def minimum_required_age
    (Setting["min_age_to_participate"] || 16).to_i
  end

  def mask_phone(number)
    match = number.match(/\d{3}$/)
    "******#{match}"
  end

  def mask_email(string)
    match = string.match(/^(\w{1,3})(.*)@(.*)/)

    data_to_display = match[1]
    data_to_mask    = match[2]
    email_provider  = match[3]

    "#{data_to_display}#{"*" * data_to_mask.size}@#{email_provider}"
  end
end
