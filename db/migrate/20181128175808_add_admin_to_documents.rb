class AddAdminToDocuments < ActiveRecord::Migration
  def change
    add_column :documents, :admin, :boolean, default: false
  end
end
