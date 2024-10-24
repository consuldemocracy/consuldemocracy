class CreateAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table :addresses do |t|
      t.integer :user_id
      t.string :street
      t.string :street_type
      t.string :number
      t.string :number_type
      t.string :letter
      t.string :portal
      t.string :stairway
      t.string :floor
      t.string :door
      t.string :km
      t.string :neighbourhood
      t.string :district
      t.string :postal_code
      t.string :toponymy

      t.timestamps null: false
    end
  end
end
