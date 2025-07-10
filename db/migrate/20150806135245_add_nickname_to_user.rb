class AddNicknameToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :nickname, :string
  end
end
