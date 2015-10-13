class RemoveUnconfirmedDocumentNumberFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :unconfirmed_document_number, :string
  end
end
