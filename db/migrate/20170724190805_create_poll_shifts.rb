class CreatePollShifts < ActiveRecord::Migration
  def change
    create_table :poll_shifts do |t|
      t.integer :booth_id
      t.integer :officer_id
      t.date :date

      t.timestamps
    end

    add_index :poll_shifts, :booth_id
    add_index :poll_shifts, :officer_id
    add_index :poll_shifts, [:booth_id, :officer_id]
  end
end
