class AddBadgeToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :official_position_badge, :boolean, default: false
  end
end
