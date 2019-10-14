class ChangesUserRegistrationsFields < ActiveRecord::Migration
  def change
    add_column :users, :username, :string

    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :nickname, :string
    remove_column :users, :use_nickname, :boolean, default: false, null: false
  end
end
