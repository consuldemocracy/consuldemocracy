class RemoveUnconfirmedDocumentNumberFromUser < ActiveRecord::Migration[4.2]
  def change
    remove_column :users, :unconfirmed_document_number, :string
  end
end
