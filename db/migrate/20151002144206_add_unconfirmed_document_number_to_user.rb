class AddUnconfirmedDocumentNumberToUser < ActiveRecord::Migration
  def change
    add_column :users, :unconfirmed_document_number, :string
  end
end
