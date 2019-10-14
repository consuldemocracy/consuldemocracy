class DefaultPasswordChangedAt < ActiveRecord::Migration
  def change
    change_column :users, :password_changed_at, :datetime, null: false, default: Time.now
  end
end
