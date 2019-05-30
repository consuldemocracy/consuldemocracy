class AddAdminToDocuments < ActiveRecord::Migration[4.2]
  def change
    add_column :documents, :admin, :boolean, default: false
  end
end
