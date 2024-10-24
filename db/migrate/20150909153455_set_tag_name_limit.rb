class SetTagNameLimit < ActiveRecord::Migration[4.2]
  def up
    execute "ALTER TABLE tags ALTER COLUMN name TYPE VARCHAR(40) USING SUBSTR(name, 1, 40)"
    change_column :tags, :name, :string, limit: 40
  end

  def down
    change_column :tags, :name, :string, limit: nil
  end
end
