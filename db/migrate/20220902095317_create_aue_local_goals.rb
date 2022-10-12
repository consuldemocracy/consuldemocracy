class CreateAUELocalGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :aue_local_goals do |t|
      t.string :code
      t.timestamps

      t.index :code, unique: true
    end
    create_table :aue_local_goal_translations do |t|
      t.bigint :aue_local_goal_id, null: false
      t.string :locale, null: false
      t.string :title
      t.text :description
      t.timestamps null: false

      t.index :locale
      t.index :aue_local_goal_id
    end
  end
end
