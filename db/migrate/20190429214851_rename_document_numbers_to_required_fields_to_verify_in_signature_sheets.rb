class RenameDocumentNumbersToRequiredFieldsToVerifyInSignatureSheets < ActiveRecord::Migration[4.2]
  def change
    rename_column :signature_sheets, :document_numbers, :required_fields_to_verify
  end
end
