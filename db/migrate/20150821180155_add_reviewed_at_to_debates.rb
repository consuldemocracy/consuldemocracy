class AddReviewedAtToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :reviewed_at, :datetime
  end
end
