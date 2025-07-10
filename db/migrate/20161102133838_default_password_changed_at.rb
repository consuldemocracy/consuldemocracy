class DefaultPasswordChangedAt < ActiveRecord::Migration[4.2]
  def change
    change_column :users, :password_changed_at, :datetime, null: false, default: Time.zone.now
  end
end
