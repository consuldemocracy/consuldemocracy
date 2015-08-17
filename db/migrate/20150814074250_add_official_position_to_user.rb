class AddOfficialPositionToUser < ActiveRecord::Migration
  def change
    add_column :users, :official_position, :string
    add_column :users, :official_level, :integer, default: 0
  end
end
