class AddErasedAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :erased_at, :datetime
  end
end
