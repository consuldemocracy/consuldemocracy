class CreateSDGPhases < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_phases do |t|
      t.integer :kind, null: false
      t.index :kind, unique: true
      t.timestamps
    end
  end
end
