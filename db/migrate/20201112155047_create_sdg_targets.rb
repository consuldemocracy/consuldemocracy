class CreateSDGTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_targets do |t|
      t.references :goal
      t.string :code, null: false
      t.timestamps

      t.index :code, unique: true
    end
  end
end
