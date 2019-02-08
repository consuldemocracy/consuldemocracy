class CreateSubArea < ActiveRecord::Migration
  def self.up
    create_table :sub_areas do |t|
      t.text :name
      t.integer :area_id, null: false

      t.timestamps        null: false
    end
  end

  def self.down
    drop_table :sub_areas
  end
end
