class CreateOfficingBooths < ActiveRecord::Migration[4.2]
  def change
    create_table :poll_officing_booths do |t|
      t.belongs_to :officer
      t.belongs_to :booth
      t.timestamps null: false
    end
  end
end
