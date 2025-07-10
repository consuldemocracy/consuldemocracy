class ChangeDebatesTitleLength < ActiveRecord::Migration[4.2]
  def change
    change_column :debates, :title, :string, limit: 80
  end
end
