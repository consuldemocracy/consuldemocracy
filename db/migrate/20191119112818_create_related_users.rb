class CreateRelatedUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :related_users do |t|
      t.references :user, index: true
      t.references :related_user, index: true

      t.timestamps
    end

    add_index :related_users, [:user_id, :related_user_id], unique: true
  end
end
