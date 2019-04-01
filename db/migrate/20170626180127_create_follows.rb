class CreateFollows < ActiveRecord::Migration[4.2]
  def change
    create_table :follows do |t|
      t.references :user, index: true, foreign_key: true
      t.references :followable, polymorphic: true, index: true

      t.timestamps null: false
    end

    add_index :follows, [:user_id, :followable_type, :followable_id], name: "access_follows"
  end
end
