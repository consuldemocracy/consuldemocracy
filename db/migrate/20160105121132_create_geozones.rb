class CreateGeozones < ActiveRecord::Migration[4.2]
  def change
    create_table :geozones do |t|
      t.string :name
      t.string :html_map_coordinates
      t.string :external_code

      t.timestamps null: false
    end
  end
end
