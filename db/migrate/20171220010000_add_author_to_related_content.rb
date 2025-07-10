class AddAuthorToRelatedContent < ActiveRecord::Migration[4.2]
  def change
    add_column :related_contents, :author_id, :integer
  end
end
