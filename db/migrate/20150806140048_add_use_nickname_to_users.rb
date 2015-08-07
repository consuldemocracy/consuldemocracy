class AddUseNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :use_nickname, :boolean, null: false, default: false
  end
end
