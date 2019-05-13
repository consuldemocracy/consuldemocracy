class CreateRelatedContentScores < ActiveRecord::Migration[4.2]
  def change
    create_table :related_content_scores do |t|
      t.references :user, index: true, foreign_key: true
      t.references :related_content, index: true, foreign_key: true
      t.integer :value
    end

    add_index :related_content_scores, [:user_id, :related_content_id], name: "unique_user_related_content_scoring", unique: true, using: :btree
  end
end
