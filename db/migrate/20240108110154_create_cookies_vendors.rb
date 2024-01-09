class CreateCookiesVendors < ActiveRecord::Migration[6.1]
  def change
    create_table :cookies_vendors do |t|
      t.string :name
      t.text :description
      t.string :cookie
      t.text :script

      t.timestamps

      t.index :cookie, unique: true
    end
  end
end
