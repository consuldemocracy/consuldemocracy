class AddBadgeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :official_position_badge, :boolean, default: false
  end
end
