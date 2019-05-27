class DestroyManager < ActiveRecord::Migration[4.2]
  def self.up
    drop_table :managers
  end

  def self.down
    create_table :managers do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.timestamp :last_login_at
      t.timestamps
    end

    add_index :managers, [:username]
  end
end
