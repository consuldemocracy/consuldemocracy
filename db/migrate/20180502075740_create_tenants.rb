class CreateTenants < ActiveRecord::Migration[4.2]
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :subdomain
      t.timestamps null: false

      t.index :subdomain, unique: true
    end
  end
end
