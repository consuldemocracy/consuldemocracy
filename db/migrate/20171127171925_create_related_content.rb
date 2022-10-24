class CreateRelatedContent < ActiveRecord::Migration[4.2]
  def change
    create_table :related_contents do |t|
      t.references :parent_relationable, polymorphic: true, index: { name: "index_related_contents_on_parent_relationable" }
      t.references :child_relationable, polymorphic: true, index: { name: "index_related_contents_on_child_relationable" }
      t.references :related_content, index: { name: "opposite_related_content" }
      t.timestamps
    end

    add_index :related_contents, [:parent_relationable_id, :parent_relationable_type, :child_relationable_id, :child_relationable_type], name: "unique_parent_child_related_content", unique: true, using: :btree
  end
end
