class CreateInappropiateFlags < ActiveRecord::Migration[4.2]
  def change
    create_table :inappropiate_flags do |t|
      t.belongs_to :user, index: true, foreign_key: true

      t.string :flaggable_type
      t.integer :flaggable_id

      t.timestamps
    end

    add_index :inappropiate_flags, [:flaggable_type, :flaggable_id]
    add_index :inappropiate_flags, [:user_id, :flaggable_type, :flaggable_id], name: "access_inappropiate_flags"
  end
end
