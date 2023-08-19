class CreateTenants < ActiveRecord::Migration[4.2]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :schema
      t.timestamps null: false

      t.index :name, unique: true
      t.index :schema, unique: true
    end
  end
end
