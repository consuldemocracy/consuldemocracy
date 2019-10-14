class CreateGeozones < ActiveRecord::Migration
  def change
    create_table :geozones do |t|
      t.string :name
      t.string :html_map_coordinates
      t.string :external_code

      t.timestamps null: false
    end
  end
end
