class ChangeDebatesTitleLength < ActiveRecord::Migration
  def change
    change_column :debates, :title, :string, limit: 80
  end
end
