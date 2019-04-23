class RenameGenreToGender < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :genre, :gender
  end
end
