class AddUseNicknameToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :use_nickname, :boolean, null: false, default: false
  end
end
