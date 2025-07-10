class RemoveFeaturedFromTags < ActiveRecord::Migration[4.2]
  def change
    remove_column :tags, :featured, :boolean, default: false
  end
end
