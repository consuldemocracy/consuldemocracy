class RemoveUserConstraints < ActiveRecord::Migration[4.2]
  def change
    change_column(:users, :email, :string, null: true, unique: true)
  end
end
