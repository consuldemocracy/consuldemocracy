class AddKindToTags < ActiveRecord::Migration
  def change
    add_column :tags, :kind, :string, limit: 40
  end
end
