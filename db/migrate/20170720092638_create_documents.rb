class CreateDocuments < ActiveRecord::Migration[4.2]
  def change
    create_table :documents do |t|
      t.string :title
      t.string :attachment_file_name
      t.string :attachment_content_type
      t.integer :attachment_file_size
      t.datetime :attachment_updated_at
      t.references :user, index: true, foreign_key: true
      t.references :documentable, polymorphic: true, index: true

      t.timestamps null: false
    end

    add_index :documents, [:user_id, :documentable_type, :documentable_id], name: "access_documents"
  end
end
