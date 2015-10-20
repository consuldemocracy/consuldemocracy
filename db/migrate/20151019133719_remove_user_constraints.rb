class RemoveUserConstraints < ActiveRecord::Migration
  def change
    change_column(:users, :email, :string, null: true, unique: true)
  end
end
