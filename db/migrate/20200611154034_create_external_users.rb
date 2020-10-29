class CreateExternalUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :external_users do |t|
      t.string :uuid, limit: 128
      t.string :fullname, limit: 512
      t.string :email, limit: 256
      t.boolean :validated

      t.timestamps
    end
    add_index :external_users, :uuid, unique: true
  end
end
