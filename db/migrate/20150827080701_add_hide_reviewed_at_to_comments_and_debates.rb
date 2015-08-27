class AddHideReviewedAtToCommentsAndDebates < ActiveRecord::Migration
  def change
    add_column :debates, :hide_reviewed_at, :datetime
    add_column :comments, :hide_reviewed_at, :datetime
  end
end
