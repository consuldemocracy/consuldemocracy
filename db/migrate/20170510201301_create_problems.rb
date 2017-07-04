class CreateProblems < ActiveRecord::Migration
  def change
    create_table :problems do |t|
      t.string :title
      t.text :description
      t.text :cause
      t.text :problem_title
      t.text :consequence
      t.string :budget
      t.text :restriction
      t.text :summary
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :geozone_restricted
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
