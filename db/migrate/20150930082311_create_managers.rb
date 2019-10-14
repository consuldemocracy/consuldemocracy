class CreateManagers < ActiveRecord::Migration
  def change
    create_table :managers do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.timestamp :last_login_at
      t.timestamps
    end

    add_index :managers, [:username]
  end
end
