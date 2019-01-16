class CreateGeographies < ActiveRecord::Migration
  def change
    create_table :geographies do |t|
      t.string :name
      t.text :outline_points
      t.string :color

      t.timestamps null: false
    end
  end
end
