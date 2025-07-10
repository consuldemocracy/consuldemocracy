class AddErasedAtToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :erased_at, :datetime
  end
end
