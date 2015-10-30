class ChangeTagsNameSize < ActiveRecord::Migration
  def change
    change_column :tags, :name, :string, limit: 400
  end
end
