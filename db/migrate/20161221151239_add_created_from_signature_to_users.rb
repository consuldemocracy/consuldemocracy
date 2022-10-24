class AddCreatedFromSignatureToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :created_from_signature, :boolean, default: false
  end
end
