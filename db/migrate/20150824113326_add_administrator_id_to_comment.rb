class AddAdministratorIdToComment < ActiveRecord::Migration
  def change
    add_column :comments, :administrator_id, :integer, default: nil
  end
end
