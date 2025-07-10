class AddsResilientLockedUntilDefault < ActiveRecord::Migration[4.2]
  def up
    change_column_default :locks, :locked_until, Time.zone.local(2000, 1, 1, 1, 1, 1)
  end

  def down
    change_column_default :locks, :locked_until, Time.zone.now
  end
end
