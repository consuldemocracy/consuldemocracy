class AddTimeZoneToDefaultDatetimes < ActiveRecord::Migration[4.2]
  def change
    change_column_default :users, :password_changed_at,
      from: Time.zone.local(2015, 1, 1, 1, 1, 1),
      to:   DateTime.new(2015, 1, 1, 1, 1, 1, "+00:00")

    change_column_default :locks, :locked_until,
      from: Time.zone.local(2000, 1, 1, 1, 1, 1),
      to:   DateTime.new(2000, 1, 1, 1, 1, 1, "+00:00")
  end
end
