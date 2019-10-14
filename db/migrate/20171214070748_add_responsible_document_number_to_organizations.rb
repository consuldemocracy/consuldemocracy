class AddResponsibleDocumentNumberToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :responsible_document_number, :string, null: nil
  end
end
