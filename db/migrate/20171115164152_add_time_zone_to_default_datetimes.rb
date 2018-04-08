class AddTimeZoneToDefaultDatetimes < ActiveRecord::Migration
  def change
    change_column_default :users, :password_changed_at, DateTime.new(2015, 1, 1,  1,  1,  1, '+00:00')
    change_column_default :locks, :locked_until, DateTime.new(2000, 1, 1,  1,  1,  1, '+00:00')
  end
end
