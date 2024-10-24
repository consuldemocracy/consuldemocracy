class AddFeaturedToTags < ActiveRecord::Migration[4.2]
  def change
    add_column :tags, :featured, :boolean, default: false
  end
end
