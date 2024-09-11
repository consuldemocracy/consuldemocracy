class CreatePostcodes < ActiveRecord::Migration[6.0]
  def change
    create_table :postcodes do |t|
      t.string :postcode
      t.string :ward
      t.integer :geozone_id
    end
  end
end
