class CreateSDGLocalTargets < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_local_targets do |t|
      t.references :target
      t.string :code
      t.timestamps

      t.index :code, unique: true
    end

    create_table :sdg_local_target_translations do |t|
      t.bigint :sdg_local_target_id, null: false
      t.string :locale, null: false
      t.string :title
      t.text :description
      t.timestamps null: false

      t.index :locale
      t.index :sdg_local_target_id
    end
  end
end
