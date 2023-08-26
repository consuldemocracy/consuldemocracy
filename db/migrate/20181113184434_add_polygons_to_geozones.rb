class AddPolygonsToGeozones < ActiveRecord::Migration[5.0]
  def change
    change_table :geozones do |t|
      t.text :geojson
      t.string :color
    end
  end
end
