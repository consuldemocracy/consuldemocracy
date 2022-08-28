class RemoveUserConstraints < ActiveRecord::Migration[4.2]
  def up
    change_column(:users, :email, :string, null: true, unique: true)
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
