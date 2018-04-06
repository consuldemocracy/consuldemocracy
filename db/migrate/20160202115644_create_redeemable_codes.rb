class CreateRedeemableCodes < ActiveRecord::Migration
  def change
    create_table :redeemable_codes do |t|
      t.string :token
      t.integer :geozone_id

      t.timestamps null: false
    end
  end
end
