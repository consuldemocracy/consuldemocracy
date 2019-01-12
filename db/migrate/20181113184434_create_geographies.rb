class CreateGeographies < ActiveRecord::Migration
  def change
    create_table :geographies do |t|
      t.string :name
      t.float :outline_points, array: true, default: []

      t.timestamps null: false
    end
  end
end
