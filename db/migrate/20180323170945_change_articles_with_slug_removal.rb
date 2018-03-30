class ChangeArticlesWithSlugRemoval < ActiveRecord::Migration
  def change
    remove_column :articles, :slug, :string, null: false, index: true
  end
end
