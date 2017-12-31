class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :title
      t.attachment :attachment
      t.references :user, index: true, foreign_key: true
      t.references :documentable, polymorphic: true, index: true

      t.timestamps null: false
    end

    add_index :documents, [:user_id, :documentable_type, :documentable_id], name: "access_documents"
  end
end
