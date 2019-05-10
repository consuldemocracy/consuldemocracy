class AddUserIdToImages < ActiveRecord::Migration[4.2]
  def change
    add_reference :images, :user, index: true, foreign_key: true
  end
end
