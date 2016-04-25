class AddFeaturedAtToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :featured_at, :datetime
  end
end
