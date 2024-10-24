class DeleteOfficingBooths < ActiveRecord::Migration[4.2]
  def up
    drop_table :poll_officing_booths
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
