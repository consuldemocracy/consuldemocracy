class IncreaseTagNameLimit < ActiveRecord::Migration
  def up
    execute "ALTER TABLE tags ALTER COLUMN name TYPE VARCHAR(160) USING SUBSTR(name, 1, 160)"
    change_column :tags, :name, :string, limit: 160
  end

  def down
    change_column :tags, :name, :string, limit: 40
  end
end
