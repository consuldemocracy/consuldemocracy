class AddLocationToBooths < ActiveRecord::Migration
  def change
    add_column :poll_booths, :location, :string
  end
end
