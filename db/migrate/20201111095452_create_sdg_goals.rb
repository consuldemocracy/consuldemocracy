class CreateSDGGoals < ActiveRecord::Migration[5.2]
  def change
    create_table :sdg_goals do |t|
      t.integer :code, null: false
      t.timestamps

      t.index :code, unique: true
    end

    create_table :sdg_goal_translations do |t|
      t.integer :sdg_goal_id, null: false
      t.string :locale, null: false
      t.timestamps null: false

      t.string :title
      t.text :description

      t.index :sdg_goal_id
      t.index :locale
      t.index [:title, :locale], unique: true
    end
  end
end
