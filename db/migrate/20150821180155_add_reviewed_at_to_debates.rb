class AddReviewedAtToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :reviewed_at, :datetime
  end
end
