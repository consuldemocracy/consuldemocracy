class AddReviewedAtToComments < ActiveRecord::Migration
  def change
    add_column :comments, :reviewed_at, :datetime
  end
end
