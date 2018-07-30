class CreateTenants < ActiveRecord::Migration
  def change
    create_table :tenants do |t|
      t.string :name
      t.string :title
      t.string :subdomain
      t.string :postal_code

      t.timestamps null: false
    end
  end
end
