class AddShiftTask < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_shifts, :task, :integer, null: false, default: 0
  end
end
