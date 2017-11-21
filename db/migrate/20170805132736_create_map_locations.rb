class CreateMapLocations < ActiveRecord::Migration
  def change
    create_table :map_locations do |t|
      t.float :latitude
      t.float :longitude
      t.integer :zoom
      t.integer :proposal_id, index: true
      t.integer :investment_id, index: true
    end
  end
end
