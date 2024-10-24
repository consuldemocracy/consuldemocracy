class DropAddressesTable < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :addresses
  end

  def self.down
    create_table "addresses", force: :cascade do |t|
      t.integer  "user_id"
      t.string   "street"
      t.string   "street_type"
      t.string   "number"
      t.string   "number_type"
      t.string   "letter"
      t.string   "portal"
      t.string   "stairway"
      t.string   "floor"
      t.string   "door"
      t.string   "km"
      t.string   "neighbourhood"
      t.string   "district"
      t.string   "postal_code"
      t.string   "toponymy"
      t.timestamps null: false
    end
  end
end
