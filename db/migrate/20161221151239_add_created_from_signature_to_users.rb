class AddCreatedFromSignatureToUsers < ActiveRecord::Migration
  def change
    add_column :users, :created_from_signature, :boolean, default: false
  end
end
