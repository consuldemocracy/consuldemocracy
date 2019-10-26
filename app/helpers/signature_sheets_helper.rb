module SignatureSheetsHelper
  def signable_options
    [[t("activerecord.models.proposal", count: 1), Proposal],
     [t("activerecord.models.budget/investment", count: 1), Budget::Investment]]
  end

  def required_fields_to_verify_text_help
    if Setting["feature.remote_census"].present?
      date_of_birth_and_postal_code_text_help
    else
      t("admin.signature_sheets.new.document_numbers_note")
    end
  end

  def date_of_birth_and_postal_code_text_help
    text_help = t("admin.signature_sheets.new.text_help.required_fields_note")

    if Setting.force_presence_date_of_birth?
      text_help += t("admin.signature_sheets.new.text_help.date_of_birth_note")
    end

    if Setting.force_presence_postal_code?
      text_help += t("admin.signature_sheets.new.text_help.postal_code_note")
    end

    text_help += tag(:br)
    text_help += t("admin.signature_sheets.new.text_help.required_fields_structure_note")

    text_help
  end

  def example_text_help
    text_example = t("admin.signature_sheets.new.text_help.example_text")
    example_1 = "12345678Z"
    example_2 = "87654321Y"

    if Setting.force_presence_date_of_birth?
      example_1 += ", 01/01/1980"
      example_2 += ", 01/02/1990"
    end

    if Setting.force_presence_postal_code?
      example_1 += ", 28001"
      example_2 += ", 28002"
    end

    text_example += "#{example_1}; #{example_2}"
    text_example
  end
end
