class ChangeTagsNameSize < ActiveRecord::Migration
  def change
    execute "ALTER TABLE tags ALTER COLUMN name TYPE VARCHAR(400)"
    change_column :tags, :name, :string, limit: 400
  end
end
