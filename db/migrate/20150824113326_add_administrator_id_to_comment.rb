class AddAdministratorIdToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :administrator_id, :integer, default: nil
  end
end
