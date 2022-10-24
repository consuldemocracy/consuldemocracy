class AddKindToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :kind, :string
  end
end
