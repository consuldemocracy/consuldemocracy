class AddUnconfirmedDocumentNumberToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :unconfirmed_document_number, :string
  end
end
