class AddDocumentToUsers < ActiveRecord::Migration
  def change
    add_column :users, :document_number, :string
    add_column :users, :document_type, :string
  end
end
