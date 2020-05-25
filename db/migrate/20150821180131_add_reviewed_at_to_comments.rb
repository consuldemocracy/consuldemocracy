class AddReviewedAtToComments < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :reviewed_at, :datetime
  end
end
