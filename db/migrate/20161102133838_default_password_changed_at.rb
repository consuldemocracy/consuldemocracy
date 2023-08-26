class DefaultPasswordChangedAt < ActiveRecord::Migration[4.2]
  def up
    change_column :users, :password_changed_at, :datetime, null: false, default: Time.zone.now
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
