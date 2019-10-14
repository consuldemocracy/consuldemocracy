class CreateCommissions < ActiveRecord::Migration
  def change
    create_table :commissions do |t|
      t.references :geozone, index: true, foreign_key: true
      t.string :name
      t.string :place
      t.string :address

      t.timestamps null: false
    end
  end
end
