class AddExtraFieldsToDebates < ActiveRecord::Migration
  def change
    add_column :debates, :likes_disallowed, :boolean, default: false, null: nil
  end
end
