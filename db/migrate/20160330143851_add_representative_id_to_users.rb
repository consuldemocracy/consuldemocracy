class AddRepresentativeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :representative_id, :integer
  end
end
