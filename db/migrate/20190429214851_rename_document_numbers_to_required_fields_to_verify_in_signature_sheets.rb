class RenameDocumentNumbersToRequiredFieldsToVerifyInSignatureSheets < ActiveRecord::Migration
  def change
    rename_column :signature_sheets, :document_numbers, :required_fields_to_verify
  end
end
