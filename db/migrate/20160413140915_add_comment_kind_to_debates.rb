class AddCommentKindToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :comment_kind, :string, default: 'comment'
  end
end
