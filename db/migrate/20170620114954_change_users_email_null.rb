class ChangeUsersEmailNull < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :email, :string, null: nil
  end
end
