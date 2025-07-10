class AddLocationToBooths < ActiveRecord::Migration[4.2]
  def change
    add_column :poll_booths, :location, :string
  end
end
