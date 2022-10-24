class AddDocumentToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :document_number, :string
    add_column :users, :document_type, :string
  end
end
