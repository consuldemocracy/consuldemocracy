class AddAuthorToRelatedContent < ActiveRecord::Migration
  def change
    add_column :related_contents, :author_id, :integer
  end
end
