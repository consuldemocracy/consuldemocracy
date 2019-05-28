class AddSlugToPolls < ActiveRecord::Migration[4.2]
  def change
    add_column :polls, :slug, :string
  end
end
