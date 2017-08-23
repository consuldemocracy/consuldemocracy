class RemoveFeaturedFromTags < ActiveRecord::Migration
  def change
    remove_column :tags, :featured, :boolean, default: false
  end
end
