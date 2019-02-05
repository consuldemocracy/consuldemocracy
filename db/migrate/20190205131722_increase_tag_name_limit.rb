class IncreaseTagNameLimit < ActiveRecord::Migration
  def up
    change_column :tags, :name, :string, limit: 160
  end

  def down
    change_column :tags, :name, :string, limit: 40
  end
end
