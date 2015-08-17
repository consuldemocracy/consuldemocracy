class AddFeaturedToTags < ActiveRecord::Migration
  def change
    add_column :tags, :featured, :boolean, default: false
  end
end
