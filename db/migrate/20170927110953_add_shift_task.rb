class AddShiftTask < ActiveRecord::Migration
  def change
    add_column :poll_shifts, :task, :integer, null: false, default: 0
  end
end
