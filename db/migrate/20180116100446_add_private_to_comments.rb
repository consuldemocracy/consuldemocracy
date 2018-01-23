class AddPrivateToComments < ActiveRecord::Migration
  def change
    add_column :comments, :concealed, :boolean, default: false
  end
end
