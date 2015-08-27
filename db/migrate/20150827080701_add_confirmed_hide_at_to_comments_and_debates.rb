class AddConfirmedHideAtToCommentsAndDebates < ActiveRecord::Migration
  def change
    add_column :debates, :confirmed_hide_at, :datetime
    add_column :comments, :confirmed_hide_at, :datetime
  end
end
