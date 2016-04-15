class AddCommentKindToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :comment_kind, :string
  end
end
