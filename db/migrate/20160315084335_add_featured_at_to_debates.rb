class AddFeaturedAtToDebates < ActiveRecord::Migration[4.2]
  def change
    add_column :debates, :featured_at, :datetime
  end
end
