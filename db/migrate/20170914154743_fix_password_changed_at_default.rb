class FixPasswordChangedAtDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :users, :password_changed_at, Time.zone.local(2015, 1, 1, 1, 1, 1)
  end

  def down
    change_column_default :users, :password_changed_at, Time.zone.now
  end
end
