class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :neighbour_id
      t.integer :responsible_id
      t.string :name
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.boolean :geozone_restricted
      t.belongs_to :proposal, index: true

      t.timestamps null: false
    end
  end
end
