class AddIndexesForSearches < ActiveRecord::Migration[4.2]
  def change
    add_index :debates, :title
    # add_index :debates, :description

    add_index :proposals, :title
    add_index :proposals, :question
    add_index :proposals, :summary
    # add_index :proposals, :description
  end
end
