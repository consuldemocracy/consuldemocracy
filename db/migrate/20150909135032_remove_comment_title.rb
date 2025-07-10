class RemoveCommentTitle < ActiveRecord::Migration[4.2]
  def change
    remove_column :comments, :title, :string
  end
end
