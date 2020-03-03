class AddOver18ToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :over18, :boolean, default: false
  end
end
